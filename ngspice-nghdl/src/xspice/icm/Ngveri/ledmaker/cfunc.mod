/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

                
        #include <stdio.h>
        #include <math.h>
        #include <string.h>
        #include "sim_main_ledmaker.h"

        
void cm_ledmaker(ARGS) 
{
	Digital_State_t *_op_passed, *_op_passed_old;
	Digital_State_t *_op_failed, *_op_failed_old;

    static int inst_count=0;
    int count=0;
        
    if(INIT)
    {   
        inst_count++;
        PARAM(instance_id)=inst_count;
        fooledmaker(0,inst_count);
        /* Allocate storage for output ports and set the load for input ports */

        
        port_clk=PORT_SIZE(clk);

        port_reset=PORT_SIZE(reset);

        port_cyc_cnt=PORT_SIZE(cyc_cnt);

        port_passed=PORT_SIZE(passed);

        port_failed=PORT_SIZE(failed);
		cm_event_alloc(0,1*sizeof(Digital_State_t));
		cm_event_alloc(1,1*sizeof(Digital_State_t));
		/* set the load for input ports. */
		int Ii;
		for(Ii=0;Ii<PORT_SIZE(clk);Ii++)
		{
			LOAD(clk[Ii])=PARAM(input_load); 
		}
		for(Ii=0;Ii<PORT_SIZE(reset);Ii++)
		{
			LOAD(reset[Ii])=PARAM(input_load); 
		}
		for(Ii=0;Ii<PORT_SIZE(cyc_cnt);Ii++)
		{
			LOAD(cyc_cnt[Ii])=PARAM(input_load); 
		}

		/*Retrieve Storage for output*/
		_op_passed = _op_passed_old = (Digital_State_t *) cm_event_get_ptr(0,0);
		_op_failed = _op_failed_old = (Digital_State_t *) cm_event_get_ptr(1,0);


	}
	else
	{
		_op_passed = (Digital_State_t *) cm_event_get_ptr(0,0);
		_op_passed_old = (Digital_State_t *) cm_event_get_ptr(0,1);
		_op_failed = (Digital_State_t *) cm_event_get_ptr(1,1);
		_op_failed_old = (Digital_State_t *) cm_event_get_ptr(1,2);
	}

	//Formating data for sending it to client
	int Ii;
	count=(int)PARAM(instance_id);

    for(Ii=0;Ii<PORT_SIZE(clk);Ii++)
    {
        if( INPUT_STATE(clk[Ii])==ZERO )
        {
            temp_clk[Ii]=0;            }
        else
        {
            temp_clk[Ii]=1;
        }
            }
    for(Ii=0;Ii<PORT_SIZE(reset);Ii++)
    {
        if( INPUT_STATE(reset[Ii])==ZERO )
        {
            temp_reset[Ii]=0;            }
        else
        {
            temp_reset[Ii]=1;
        }
            }
    for(Ii=0;Ii<PORT_SIZE(cyc_cnt);Ii++)
    {
        if( INPUT_STATE(cyc_cnt[Ii])==ZERO )
        {
            temp_cyc_cnt[Ii]=0;            }
        else
        {
            temp_cyc_cnt[Ii]=1;
        }
            }
	fooledmaker(1,count);

	/* Scheduling event and processing them */
    for(Ii=0;Ii<PORT_SIZE(passed);Ii++)
    {
        if(temp_passed[Ii]==0)
        {
            _op_passed[Ii]=ZERO;
            }
        else if(temp_passed[Ii]==1)
        {
            _op_passed[Ii]=ONE;
            }
        else
        {
            printf("Unknown value\n");
                }

        if(ANALYSIS == DC)
        {
            OUTPUT_STATE(passed[Ii]) = _op_passed[Ii];
            }
        else if(_op_passed[Ii] != _op_passed_old[Ii])
        {
            OUTPUT_STATE(passed[Ii]) = _op_passed[Ii];
            OUTPUT_DELAY(passed[Ii]) = ((_op_passed[Ii] == ZERO) ? PARAM(fall_delay) : PARAM(rise_delay));
            }
        else
        {
            OUTPUT_CHANGED(passed[Ii]) = FALSE;
            }
        OUTPUT_STRENGTH(passed[Ii]) = STRONG;
    }
	/* Scheduling event and processing them */
    for(Ii=0;Ii<PORT_SIZE(failed);Ii++)
    {
        if(temp_failed[Ii]==0)
        {
            _op_failed[Ii]=ZERO;
            }
        else if(temp_failed[Ii]==1)
        {
            _op_failed[Ii]=ONE;
            }
        else
        {
            printf("Unknown value\n");
                }

        if(ANALYSIS == DC)
        {
            OUTPUT_STATE(failed[Ii]) = _op_failed[Ii];
            }
        else if(_op_failed[Ii] != _op_failed_old[Ii])
        {
            OUTPUT_STATE(failed[Ii]) = _op_failed[Ii];
            OUTPUT_DELAY(failed[Ii]) = ((_op_failed[Ii] == ZERO) ? PARAM(fall_delay) : PARAM(rise_delay));
            }
        else
        {
            OUTPUT_CHANGED(failed[Ii]) = FALSE;
            }
        OUTPUT_STRENGTH(failed[Ii]) = STRONG;
    }

}