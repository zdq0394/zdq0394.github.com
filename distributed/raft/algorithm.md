# The Raft Consensus Algorithm
## State
```text
Persistent state on all servers:
(Updated on stable storage before responding to RPCs)
currentTerm     latest term server has seen(initialized to 0 on first boot, increases monotonically)
votedFor        candidateId that received vote in current term(or nil if none)
log[]           log entries; each entry contains command for state machine, and term when entry was received by leader(first index is 1)

Volatile state on all servers:
commitIndex     index of highest log entry known to be committed(initialized to 0, increases monotonically)
lastApplied     index of highest log entry applied to state machine(initialized to 0, increases monotonically)

Volaile state on leader:
(Reinitialized after election)
nextIndex[]     for each server, index of the next log entry to send to that server(initialized to leader last log index + 1)
matchIndex[]    for each server, index of highest log entry known to be replicated on server(initialized to 0, increases monotonically)
```

## RequestVote RPC
```text
Arguments:
term            candidate's term
candidatedId    candidate requesting vote
lastLogIndex    index of candidate's last log entry
lastLogTerm     term of candidate's last log entry

Results:
term            currentTerm, for candidate to update itself
voteGranted     true means candidate received vote

Receiver implementation:
1. Reply false if term < currentTerm
2. If votedFor is null or candidatedId, and candidate's log is at least as up-to-date as receiver's log, grant vote
```

## AppendEntriesRPC
```text
Arguments:
term            leader's term
leaderId        so follower can redirect clients
prevLogIndex    index of log entry immediately preceding new ones
prevLogTerm     term of prevLogIndex entry
entries[]       log entries to store(empty for heartbeat; may send more than one for efficiency)
leaderCommit    leader's commitIndex

Results:
term            currentTerm, for leader to update itself
success         true if follower contained entry matching prevLogIndex and preLogTerm

Receiver implementation:
1. Reply false if term < currentTerm
2. Reply false if log doesn't contain an entry at prevLogIndex whose term matches pervLogTerm
3. If an existing entry conflicts with a new one(same index but different terms), delete the existing entry and all that follow it
4. Append any new entries not already in the log
5. If leaderCommit > commitIndex, set commitIndex=min(leaderCommit, index of last new entry)
```

## Rules for Servers
```text
All Servers
* If commitIndex > lastApplied: increment lastApplied, apply log[lastApplied] to state machine
* If RPC request or response contains term T > currentTerm: set currentTerm = T, convert to follower

Followers
* Respond to RPC's from candidates and leaders
* If election timeout elapses without receiving AppendEntries RPC from current leader or granting vote to candidate: convert to candidate

Candidates
* On conversion to candidate, start election:
    * Increment currentTerm
    * Vote for self
    * Reset election timer
    * Send RequestVote RPCs to all other servers
* If votes received from majority of servers: become leader
* If AppendEntries RPC received from new leader: convert to follower
* If election timeout elapses: start new election

Leaders
* Upon election: send initial empty AppendEntries RPCs(heartbeat) to each server; repeat during idle periods to prevent election timeouts
* If command received from client: append entry to local log, respond after entry applied to state machine
* If last log index >= nextIndex for a follower: send AppendEntries RPC with log entries starting at nextIndex
    * If successful: update nextIndex and matchIndex for follower
    * If AppendEntries fails because of log inconsistency: decrement nextIndex and retry
* If there exists an N such that N > commmitIndex, a majority of matchIndex[i]>=N, and log[N].term==currentTerm: set commitIndex = N
```