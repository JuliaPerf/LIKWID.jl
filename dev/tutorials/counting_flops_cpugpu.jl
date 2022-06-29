# In particular, the event "SMSP\_SASS\_THREAD\_INST\_EXECUTED\_OP\_FFMA\_PRED\_ON\_SUM" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above
events["SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM"] == 2 * N
