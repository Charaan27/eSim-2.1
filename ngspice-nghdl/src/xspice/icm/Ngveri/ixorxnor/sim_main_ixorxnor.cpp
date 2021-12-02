/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vixorxnor.h"
        #include <stdio.h>
        #include <stdio.h>
        #include <fstream>
        #include <stdlib.h>
        #include <string>
        #include <iostream>
        #include <cstring>
        using namespace std;
        
        extern "C" int temp_a[1024];
        extern "C" int port_a;
        extern "C" int temp_b[1024];
        extern "C" int port_b;
        extern "C" int temp_yXOR[1024];
        extern "C" int port_yXOR;
        extern "C" int temp_yXNOR[1024];
        extern "C" int port_yXNOR;
        extern "C" int fooixorxnor(int,int);
        
        void int2arrixorxnor(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intixorxnor(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int fooixorxnor(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vixorxnor* ixorxnor[1024];
            count--;
            if (init==0) 
            {
                ixorxnor[count]=new Vixorxnor{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============ixorxnor : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("a=%d\n", ixorxnor[count] ->a);
				printf("b=%d\n", ixorxnor[count] ->b);
				printf("yXOR=%d\n", ixorxnor[count] ->yXOR);
				printf("yXNOR=%d\n", ixorxnor[count] ->yXNOR);
				ixorxnor[count]->a = arr2intixorxnor(temp_a, port_a);
				ixorxnor[count]->b = arr2intixorxnor(temp_b, port_b);
				ixorxnor[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("a=%d\n", ixorxnor[count] ->a);
				printf("b=%d\n", ixorxnor[count] ->b);
				printf("yXOR=%d\n", ixorxnor[count] ->yXOR);
				printf("yXNOR=%d\n", ixorxnor[count] ->yXNOR);
				int2arrixorxnor(ixorxnor[count] -> yXOR, temp_yXOR, port_yXOR);
				int2arrixorxnor(ixorxnor[count] -> yXNOR, temp_yXNOR, port_yXNOR);

            }
            return 0;
        }