/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Fahim, Rahul at IIT Bombay */

                
        #include <stdio.h>
        #include <math.h>
        #include <string.h>
        #include <time.h>
        #include <sys/types.h>
        #include <stdlib.h>
        #include <unistd.h>
        #include <errno.h>

        
            #include <sys/socket.h>
            #include <netinet/in.h>
            #include <netdb.h>
            
void cm_nand_gate(ARGS) 
{
	Digital_State_t *_op_c, *_op_c_old;

            // Declaring components of Client
            FILE *log_client = NULL;
            log_client=fopen("client.log","a");
            int bytes_recieved;
            char send_data[1024];
            char recv_data[1024];
            char *key_iter;
            struct hostent *host;
            struct sockaddr_in server_addr;
            int sock_port = 5000+PARAM(instance_id);
        
                int socket_fd;
            	char temp_a[1024];
	char temp_b[1024];


            if(INIT)
            {
                /* Allocate storage for output ports and set the load for input ports */
        		cm_event_alloc(0,1*sizeof(Digital_State_t));
		/* set the load for input ports. */
		int Ii;
		for(Ii=0;Ii<PORT_SIZE(a);Ii++)
		{
			LOAD(a[Ii])=PARAM(input_load); 
		}
		for(Ii=0;Ii<PORT_SIZE(b);Ii++)
		{
			LOAD(b[Ii])=PARAM(input_load); 
		}

		/*Retrieve Storage for output*/
		_op_c = _op_c_old = (Digital_State_t *) cm_event_get_ptr(0,0);

                /*Taking system time info for log */
                time_t systime;
                systime = time(NULL);
                printf(ctime(&systime));
                printf("Client-Initialising GHDL...\n\n");
                fprintf(log_client,"Setup Client Server Connection at %s \n",ctime(&systime));
        

                /* Client Setup IP Addr */
                FILE *fptr;
                int ip_count = 0;
                char* my_ip = malloc(16);

                char ip_filename[100];
        
                    sprintf(ip_filename, "/tmp/NGHDL_COMMON_IP_%d.txt", getpid());
            
                fptr = fopen(ip_filename, "r");
                if (fptr)
                {
                    char line_ip[20];
                    int line_port;
                    while(fscanf(fptr, "%s %d", line_ip, &line_port) == 2) {
                        ip_count++;
                    }

                    fclose(fptr);
                }

                if (ip_count < 254) {
                    sprintf(my_ip, "127.0.0.%d", ip_count+1);
                } else {
                    sprintf(my_ip, "127.0.%d.1", (ip_count+3)%256);
                }

                fptr = fopen(ip_filename, "a");
                if (fptr)
                {
                    fprintf(fptr, "%s %d\n", my_ip, sock_port);
                    fclose(fptr);
                } else {
                    perror("Client - cannot open Common_IP file ");
                    exit(1);
                }

                STATIC_VAR(my_ip) = my_ip;
        
		char command[1024];
		snprintf(command,1024,"/home/sumanto/ngspice-nghdl/src/xspice/icm/ghdl/nand_gate/DUTghdl/start_server.sh %d %s &", sock_port, my_ip);
		system(command);
	}
	else
	{
		_op_c = (Digital_State_t *) cm_event_get_ptr(0,0);
		_op_c_old = (Digital_State_t *) cm_event_get_ptr(0,1);
	}


            /* Client Fetch IP Addr */
        
            char* my_ip = STATIC_VAR(my_ip);

            host = gethostbyname(my_ip);
            fprintf(log_client,"Creating client socket \n");
        
            //Creating socket for client
            if ((socket_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
            {
                perror("Client - Error while creating client Socket ");
                fprintf(log_client,"Error while creating client socket \n");
                exit(1);
            }

            printf("Client-Socket (Id : %d) created\n", socket_fd);
            fprintf(log_client,"Client-Client Socket created successfully \n");
            fprintf(log_client,"Client- Socket Id : %d \n",socket_fd);

            // memset(&server_addr, 0, sizeof(server_addr));
            server_addr.sin_family = AF_INET;
            server_addr.sin_port = htons(sock_port);
            server_addr.sin_addr = *((struct in_addr *)host->h_addr);
            bzero(&(server_addr.sin_zero),8);

        
            fprintf(log_client,"Client-Connecting to server \n");

            //Connecting to server
            int try_limit=10;
            while(try_limit>0)
            {
                if (connect(socket_fd, (struct sockaddr*)&server_addr,sizeof(struct sockaddr)) == -1)
                {
                    sleep(1);
                    try_limit--;
                    if(try_limit==0)
                    {
                        fprintf(stderr,"Connect- Error:Tried to connect server on port,failed...giving up \n");
                        fprintf(log_client,"Connect- Error:Tried to connect server on port, failed...giving up \n");
                        exit(1);
                    }
                }
                else
                {
                    printf("Client-Connected to server \n");
                    fprintf(log_client,"Client-Connected to server \n");
                    break;
                }
            }
        	//Formating data for sending it to client
	int Ii;

	for(Ii=0;Ii<PORT_SIZE(a);Ii++)
        	{
		if( INPUT_STATE(a[Ii])==ZERO )
        		{
			temp_a[Ii]='0';
		}
        		else
		{
			temp_a[Ii]='1';
        		}
	}
	temp_a[Ii]='\0';

	for(Ii=0;Ii<PORT_SIZE(b);Ii++)
        	{
		if( INPUT_STATE(b[Ii])==ZERO )
        		{
			temp_b[Ii]='0';
		}
        		else
		{
			temp_b[Ii]='1';
        		}
	}
	temp_b[Ii]='\0';

	//Sending and receiving data to-from server 
	snprintf(send_data,sizeof(send_data),"a:%s,b:%s", temp_a,temp_b);

            if ( send(socket_fd,send_data,sizeof(send_data),0)==-1)
            {
                fprintf(stderr, "Client-Failure Sending Message \n");
        
                    close(socket_fd);
            
                exit(1);
            }
            else
            {
                printf("Client-Message sent: %s \n",send_data);
                fprintf(log_client,"Socket Id : %d & Message sent : %s \n",socket_fd,send_data);
            }

        

            bytes_recieved=recv(socket_fd,recv_data,sizeof(recv_data),0);
            if ( bytes_recieved <= 0 )
            {
                perror("Client-Either Connection Closed or Error ");
                exit(1);
            }
            recv_data[bytes_recieved] = '\0';

            printf("Client-Message Received -  %s\n\n",recv_data);
            fprintf(log_client,"Message Received From Server-%s\n",recv_data);

        	/* Scheduling event and processing them */
        	if((key_iter=strstr(recv_data, "c:")) != NULL)
        	{
        		while(*key_iter++ != ':');
        		for(Ii=0;*key_iter != ';';Ii++,key_iter++)
        		{
        			fprintf(log_client,"Client-Bit val is %c \n",*key_iter);
        			if(*key_iter=='0')
			{
        				_op_c[Ii]=ZERO;
			}
        			else if(*key_iter=='1')
			{
        				_op_c[Ii]=ONE;
        			}
			else
			{
        				fprintf(log_client,"Unknown value return from server \n");        
				printf("Client-Unknown value return \n");
			}

        			if(ANALYSIS == DC)
			{
        				OUTPUT_STATE(c[Ii]) = _op_c[Ii];
        			}
			else if(_op_c[Ii] != _op_c_old[Ii])
        			{
				OUTPUT_STATE(c[Ii]) = _op_c[Ii];
        				OUTPUT_DELAY(c[Ii]) = ((_op_c[Ii] == ZERO) ? PARAM(fall_delay) : PARAM(rise_delay));
        			}
			else
			{
        				OUTPUT_CHANGED(c[Ii]) = FALSE;
			}
        			OUTPUT_STRENGTH(c[Ii]) = STRONG;
        		}
        	}
	close(socket_fd);

	fclose(log_client);
}