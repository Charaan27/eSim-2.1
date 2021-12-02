/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

                
        #include <stdio.h>
        #include <math.h>
        #include <string.h>
        #include "sim_main_calculator.h"

        
void cm_calculator(ARGS) 
{
	Digital_State_t *_op_res, *_op_res_old;
	Digital_State_t *_op_seven_out, *_op_seven_out_old;

    static int inst_count=0;
    int count=0;
        
    if(INIT)
    {   
        inst_count++;
        PARAM(instance_id)=inst_count;
        foocalculator(0,inst_count);
        /* Allocate storage for output ports and set the load for input ports */

        
        port_astr=PORT_SIZE(astr);

        port_res=PORT_SIZE(res);

        port_seven_out=PORT_SIZE(seven_out);
		cm_event_alloc(0,4*sizeof(Digital_State_t));
		cm_event_alloc(1,7*sizeof(Digital_State_t));
		/* set the load for input ports. */
		int Ii;
		for(Ii=0;Ii<PORT_SIZE(astr);Ii++)
		{
			LOAD(astr[Ii])=PARAM(input_load); 
		}

		/*Retrieve Storage for output*/
		_op_res = _op_res_old = (Digital_State_t *) cm_event_get_ptr(0,0);
		_op_seven_out = _op_seven_out_old = (Digital_State_t *) cm_event_get_ptr(1,0);


	}
	else
	{
		_op_res = (Digital_State_t *) cm_event_get_ptr(0,0);
		_op_res_old = (Digital_State_t *) cm_event_get_ptr(0,1);
		_op_seven_out = (Digital_State_t *) cm_event_get_ptr(1,1);
		_op_seven_out_old = (Digital_State_t *) cm_event_get_ptr(1,2);
	}

	//Formating data for sending it to client
	int Ii;
	count=(int)PARAM(instance_id);

    for(Ii=0;Ii<PORT_SIZE(astr);Ii++)
    {
        if( INPUT_STATE(astr[Ii])==ZERO )
        {
            temp_astr[Ii]=0;            }
        else
        {
            temp_astr[Ii]=1;
        }
            }
	foocalculator(1,count);

	/* Scheduling event and processing them */
    for(Ii=0;Ii<PORT_SIZE(res);Ii++)
    {
        if(temp_res[Ii]==0)
        {
            _op_res[Ii]=ZERO;
            }
        else if(temp_res[Ii]==1)
        {
            _op_res[Ii]=ONE;
            }
        else
        {
            printf("Unknown value\n");
                }

        if(ANALYSIS == DC)
        {
            OUTPUT_STATE(res[Ii]) = _op_res[Ii];
            }
        else if(_op_res[Ii] != _op_res_old[Ii])
        {
            OUTPUT_STATE(res[Ii]) = _op_res[Ii];
            OUTPUT_DELAY(res[Ii]) = ((_op_res[Ii] == ZERO) ? PARAM(fall_delay) : PARAM(rise_delay));
            }
        else
        {
            OUTPUT_CHANGED(res[Ii]) = FALSE;
            }
        OUTPUT_STRENGTH(res[Ii]) = STRONG;
    }
	/* Scheduling event and processing them */
    for(Ii=0;Ii<PORT_SIZE(seven_out);Ii++)
    {
        if(temp_seven_out[Ii]==0)
        {
            _op_seven_out[Ii]=ZERO;
            }
        else if(temp_seven_out[Ii]==1)
        {
            _op_seven_out[Ii]=ONE;
            }
        else
        {
            printf("Unknown value\n");
                }

        if(ANALYSIS == DC)
        {
            OUTPUT_STATE(seven_out[Ii]) = _op_seven_out[Ii];
            }
        else if(_op_seven_out[Ii] != _op_seven_out_old[Ii])
        {
            OUTPUT_STATE(seven_out[Ii]) = _op_seven_out[Ii];
            OUTPUT_DELAY(seven_out[Ii]) = ((_op_seven_out[Ii] == ZERO) ? PARAM(fall_delay) : PARAM(rise_delay));
            }
        else
        {
            OUTPUT_CHANGED(seven_out[Ii]) = FALSE;
            }
        OUTPUT_STRENGTH(seven_out[Ii]) = STRONG;
    }

}