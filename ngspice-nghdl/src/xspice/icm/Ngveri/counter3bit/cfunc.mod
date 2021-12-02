/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

                
        #include <stdio.h>
        #include <math.h>
        #include <string.h>
        #include "sim_main_counter3bit.h"

        
void cm_counter3bit(ARGS) 
{
	Digital_State_t *_op_out, *_op_out_old;

    static int inst_count=0;
    int count=0;
        
    if(INIT)
    {   
        inst_count++;
        PARAM(instance_id)=inst_count;
        foocounter3bit(0,inst_count);
        /* Allocate storage for output ports and set the load for input ports */

        
        port_clk=PORT_SIZE(clk);

        port_rst=PORT_SIZE(rst);

        port_out=PORT_SIZE(out);
		cm_event_alloc(0,3*sizeof(Digital_State_t));
		/* set the load for input ports. */
		int Ii;
		for(Ii=0;Ii<PORT_SIZE(clk);Ii++)
		{
			LOAD(clk[Ii])=PARAM(input_load); 
		}
		for(Ii=0;Ii<PORT_SIZE(rst);Ii++)
		{
			LOAD(rst[Ii])=PARAM(input_load); 
		}

		/*Retrieve Storage for output*/
		_op_out = _op_out_old = (Digital_State_t *) cm_event_get_ptr(0,0);


	}
	else
	{
		_op_out = (Digital_State_t *) cm_event_get_ptr(0,0);
		_op_out_old = (Digital_State_t *) cm_event_get_ptr(0,1);
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
    for(Ii=0;Ii<PORT_SIZE(rst);Ii++)
    {
        if( INPUT_STATE(rst[Ii])==ZERO )
        {
            temp_rst[Ii]=0;            }
        else
        {
            temp_rst[Ii]=1;
        }
            }
	foocounter3bit(1,count);

	/* Scheduling event and processing them */
    for(Ii=0;Ii<PORT_SIZE(out);Ii++)
    {
        if(temp_out[Ii]==0)
        {
            _op_out[Ii]=ZERO;
            }
        else if(temp_out[Ii]==1)
        {
            _op_out[Ii]=ONE;
            }
        else
        {
            printf("Unknown value\n");
                }

        if(ANALYSIS == DC)
        {
            OUTPUT_STATE(out[Ii]) = _op_out[Ii];
            }
        else if(_op_out[Ii] != _op_out_old[Ii])
        {
            OUTPUT_STATE(out[Ii]) = _op_out[Ii];
            OUTPUT_DELAY(out[Ii]) = ((_op_out[Ii] == ZERO) ? PARAM(fall_delay) : PARAM(rise_delay));
            }
        else
        {
            OUTPUT_CHANGED(out[Ii]) = FALSE;
            }
        OUTPUT_STRENGTH(out[Ii]) = STRONG;
    }

}