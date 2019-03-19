# Raft State Machine Safety Property
## Election Safety
At most one leader can be elected in a given term。
## Leader Append-Only
A leader never overwrites or deletes entries in its log; it only appends new entries。
## Log Matching
If two logs contain an entry with the same index and term, then the logs are identical in all entries up through the given index。
## Leader Completeness
If a log entry is committed in a given term, then that entry will be present in the logs of the leaders for all higher-numbered terms。
## State Machine Safety
If a server has applied a log entry at a given index to its state machine, no other server will ever apply a different log entry for the same index。