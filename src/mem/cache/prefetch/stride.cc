/*
 * Copyright (c) 2018 Inria
 * Copyright (c) 2012-2013, 2015 ARM Limited
 * All rights reserved
 *
 * The license below extends only to copyright in the software and shall
 * not be construed as granting a license to any other intellectual
 * property including but not limited to intellectual property relating
 * to a hardware implementation of the functionality of the software
 * licensed hereunder.  You may use the software subject to the license
 * terms below provided that you ensure that this notice is replicated
 * unmodified and in its entirety in all distributions of the software,
 * modified or unmodified, in source code or in binary form.
 *
 * Copyright (c) 2005 The Regents of The University of Michigan
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met: redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer;
 * redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution;
 * neither the name of the copyright holders nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @file
 * Stride Prefetcher template instantiations.
 */

#include "mem/cache/prefetch/stride.hh"

#include <cassert>

#include "base/intmath.hh"
#include "base/logging.hh"
#include "base/random.hh"
#include "base/trace.hh"
#include "cpu/base.hh"
#include "debug/HWPrefetch.hh"
#include "mem/cache/prefetch/associative_set_impl.hh"
#include "mem/cache/replacement_policies/base.hh"
#include "params/StridePrefetcher.hh"

namespace Prefetcher {

Stride::StrideEntry::StrideEntry(const SatCounter& init_confidence)
  : TaggedEntry(), confidence(init_confidence)
{
    invalidate();
}

void
Stride::StrideEntry::invalidate()
{
    lastAddr = 0;
    stride = 0;
    confidence.reset();
}

Stride::Stride(const StridePrefetcherParams *p)
  : Queued(p),
    initConfidence(p->confidence_counter_bits, p->initial_confidence),
    threshConf(p->confidence_threshold/100.0),
    useMasterId(p->use_master_id),
    // startDegree(p->start_degree),
    degree(p->degree),
    // epochCycles(p->epoch_cycles),
    intervalBlocks(p->interval_blocks),
    A_high(p->A_high),
    A_low(p->A_low),
    T_lateness(p->T_lateness),
    T_pollution(p->T_pollution),
    fdp(p->useFDP),
    pcTableInfo(p->table_assoc, p->table_entries, p->table_indexing_policy,
        p->table_replacement_policy),
    last_interval(0),
    // degree(startDegree)
    current_degree(degree),
    int_usefulPrefetches(0), int_issuedPrefetches(0), int_latePrefetches(0),
    int_demandMisses(0), int_pollutionTotal(0),
    old_usefulPrefetches(0), old_issuedPrefetches(0), old_latePrefetches(0),
    old_demandMisses(0), old_pollutionTotal(0),
    cur_usefulPrefetches(0), cur_issuedPrefetches(0), cur_latePrefetches(0),
    cur_demandMisses(0), cur_pollutionTotal(0)
{
}

Stride::PCTable*
Stride::findTable(int context)
{
    // Check if table for given context exists
    auto it = pcTables.find(context);
    if (it != pcTables.end())
        return &it->second;

    // If table does not exist yet, create one
    return allocateNewContext(context);
}

Stride::PCTable*
Stride::allocateNewContext(int context)
{
    // Create new table
    auto insertion_result = pcTables.insert(std::make_pair(context,
        PCTable(pcTableInfo.assoc, pcTableInfo.numEntries,
        pcTableInfo.indexingPolicy, pcTableInfo.replacementPolicy,
        StrideEntry(initConfidence))));

    DPRINTF(HWPrefetch, "Adding context %i with stride entries\n", context);

    // Get iterator to new pc table, and then return a pointer to the new table
    return &(insertion_result.first->second);
}

void
Stride::calculatePrefetch(const PrefetchInfo &pfi,
                                    std::vector<AddrPriority> &addresses)
{
    if (!pfi.hasPC()) {
        DPRINTF(HWPrefetch, "Ignoring request with no PC.\n");
        return;
    }

    // Get required packet info
    Addr pf_addr = pfi.getAddr();
    Addr pc = pfi.getPC();
    bool is_secure = pfi.isSecure();
    MasterID master_id = useMasterId ? pfi.getMasterId() : 0;

    // Get corresponding pc table
    PCTable* pcTable = findTable(master_id);

    // Search for entry in the pc table
    StrideEntry *entry = pcTable->findEntry(pc, is_secure);

    if (entry != nullptr) {
        pcTable->accessEntry(entry);

        // Hit in table
        int new_stride = pf_addr - entry->lastAddr;
        bool stride_match = (new_stride == entry->stride);

        // Adjust confidence for stride entry
        if (stride_match && new_stride != 0) {
            entry->confidence++;
        } else {
            entry->confidence--;
            // If confidence has dropped below the threshold, train new stride
            if (entry->confidence.calcSaturation() < threshConf) {
                entry->stride = new_stride;
            }
        }

        DPRINTF(HWPrefetch, "Hit: PC %x pkt_addr %x (%s) stride %d (%s), "
                "conf %d\n", pc, pf_addr, is_secure ? "s" : "ns",
                new_stride, stride_match ? "match" : "change",
                (int)entry->confidence);

        entry->lastAddr = pf_addr;

        // Abort prefetch generation if below confidence threshold
        if (entry->confidence.calcSaturation() < threshConf) {
            return;
        }

        if (fdp){
            if ((evictedBlocks - last_interval)>intervalBlocks){
                cur_usefulPrefetches =  0.5*old_usefulPrefetches +
                                    0.5*(usedPrefetches-int_usefulPrefetches);
                cur_issuedPrefetches =  0.5*old_issuedPrefetches +
                                0.5*(issuedPrefetches-int_issuedPrefetches);
                cur_latePrefetches = 0.5*old_latePrefetches +
                                    0.5*(latePrefetches-int_latePrefetches);
                cur_demandMisses = 0.5*old_demandMisses +
                                    0.5*(demandMisses-int_demandMisses);
                cur_pollutionTotal = 0.5*old_pollutionTotal +
                                    0.5*(pollutionTotal-int_pollutionTotal);
                double prefetch_accuracy =
                    cur_usefulPrefetches / cur_issuedPrefetches;
                double prefetch_lateness =
                    cur_latePrefetches / cur_usefulPrefetches;
                double cache_pollution =
                    cur_pollutionTotal / cur_demandMisses;

            // Logic to implement the conditions used in paper
            // Can be simplified
            if (prefetch_accuracy>A_high){
                if (prefetch_lateness>T_lateness){
                    if (current_degree<64){
                        current_degree = current_degree*2;
                    }
                }
                else{
                    if (cache_pollution>T_pollution){
                        if (current_degree>4){
                            current_degree = current_degree/2;
                        }
                    }
                }
            }
            else if (prefetch_accuracy>A_low){
                if (prefetch_lateness>T_lateness){
                    if (cache_pollution>T_pollution){
                        if (current_degree>4){
                            current_degree = current_degree/2;
                        }
                    }
                    else{
                        if (current_degree<64){
                            current_degree = current_degree*2;
                        }
                    }
                }
                else{
                    if (cache_pollution>T_pollution){
                        if (current_degree>4){
                            current_degree = current_degree/2;
                        }
                    }
                }
            }
            else{
                if (prefetch_lateness>T_lateness){
                    if (current_degree>4){
                        current_degree = current_degree/2;
                    }
                }
                else{
                    if (cache_pollution>T_pollution){
                        if (current_degree>4){
                            current_degree = current_degree/2;
                        }
                    }
                }
            }

                last_interval = evictedBlocks;
                //Initializtion for the beginning of next interval
                int_usefulPrefetches = usedPrefetches;
                int_issuedPrefetches = issuedPrefetches;
                int_latePrefetches = latePrefetches;
                int_demandMisses = demandMisses;
                int_pollutionTotal = pollutionTotal;
                // Update old counters
                old_usefulPrefetches = cur_usefulPrefetches;
                old_issuedPrefetches = cur_issuedPrefetches;
                old_latePrefetches = cur_latePrefetches;
                old_demandMisses = cur_demandMisses;
                old_pollutionTotal = cur_pollutionTotal;
                // For Dumping it to stats.txt
                pfAccuracy = prefetch_accuracy;
                testUsefulPrefetches = usedPrefetches;
                testIssuedPrefetches = issuedPrefetches;
                testLatePrefetches = latePrefetches;
                testDemandMisses = demandMisses;
                testPollutionTotal = pollutionTotal;
                testEvictedBlocks = evictedBlocks;
                CurrentDegree = current_degree;
            }
        }

        // Generate up to current_degree prefetches
        for (int d = 1; d <= current_degree; d++) {
            // Round strides up to atleast 1 cacheline
            int prefetch_stride = new_stride;
            if (abs(new_stride) < blkSize) {
                prefetch_stride = (new_stride < 0) ? -blkSize : blkSize;
            }

            Addr new_addr = pf_addr + d * prefetch_stride;
            addresses.push_back(AddrPriority(new_addr, 0));
        }
    } else {
        // Miss in table
        DPRINTF(HWPrefetch, "Miss: PC %x pkt_addr %x (%s)\n", pc, pf_addr,
                is_secure ? "s" : "ns");

        StrideEntry* entry = pcTable->findVictim(pc);

        // Insert new entry's data
        entry->lastAddr = pf_addr;
        pcTable->insertEntry(pc, is_secure, entry);
    }
}

void
Stride::regStats()
{
    ClockedObject::regStats();

    pfAccuracy
        .name(name() + ".pf_accuracy")
        .desc("accuracy of the prefetcher")
        ;

    testUsefulPrefetches
        .name(name() + ".test_useful_prefetches")
        .desc("just to check the value of useful prefetches")
        ;

    testIssuedPrefetches
        .name(name() + ".test_issued_prefetches")
        .desc("just to check the value of issued prefetches")
        ;

    testLatePrefetches
        .name(name() + ".test_late_prefetches")
        .desc("just to check the value of late prefetches")
        ;

    testDemandMisses
        .name(name() + ".test_demand_misses")
        .desc("just to check the value of demand misses")
        ;

    testPollutionTotal
        .name(name() + ".test_pollution_total")
        .desc("just to check the value of pollution total")
        ;

    testEvictedBlocks
        .name(name() + ".test_evicted_blocks")
        .desc("just to check the value of evicted blocks")
        ;

    CurrentDegree
        .name(name() + ".current_degree")
        .desc("just to check if it changes the degree")
        ;

}

inline uint32_t
StridePrefetcherHashedSetAssociative::extractSet(const Addr pc) const
{
    const Addr hash1 = pc >> 1;
    const Addr hash2 = hash1 >> tagShift;
    return (hash1 ^ hash2) & setMask;
}

Addr
StridePrefetcherHashedSetAssociative::extractTag(const Addr addr) const
{
    return addr;
}

} // namespace Prefetcher

Prefetcher::StridePrefetcherHashedSetAssociative*
StridePrefetcherHashedSetAssociativeParams::create()
{
    return new Prefetcher::StridePrefetcherHashedSetAssociative(this);
}

Prefetcher::Stride*
StridePrefetcherParams::create()
{
    return new Prefetcher::Stride(this);
}

