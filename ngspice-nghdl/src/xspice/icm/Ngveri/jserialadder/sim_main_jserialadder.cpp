/* This is cfunc.mod file auto generated by gen_con_info.py
        Developed by Sumanto Kar at IIT Bombay */

        
        #include <memory>
        #include <verilated.h>
        #include "Vjserialadder.h"
        #include <stdio.h>
        #include <stdio.h>
        #include <fstream>
        #include <stdlib.h>
        #include <string>
        #include <iostream>
        #include <cstring>
        using namespace std;
        
        extern "C" int temp_clk[1024];
        extern "C" int port_clk;
        extern "C" int temp_rst[1024];
        extern "C" int port_rst;
        extern "C" int temp_a[1024];
        extern "C" int port_a;
        extern "C" int temp_b[1024];
        extern "C" int port_b;
        extern "C" int temp_carryin[1024];
        extern "C" int port_carryin;
        extern "C" int temp_y[1024];
        extern "C" int port_y;
        extern "C" int temp_carryout[1024];
        extern "C" int port_carryout;
        extern "C" int temp_isValid[1024];
        extern "C" int port_isValid;
        extern "C" int temp_currentsum[1024];
        extern "C" int port_currentsum;
        extern "C" int temp_currentcarryout[1024];
        extern "C" int port_currentcarryout;
        extern "C" int temp_currentbitcount[1024];
        extern "C" int port_currentbitcount;
        extern "C" int foojserialadder(int,int);
        
        void int2arrjserialadder(int  num, int array[], int n)
        {   
            for (int i = 0; i < n && num>=0; i++) 
            {
                array[n-i-1] = num % 2;
                num /= 2;
                }
        }
        int arr2intjserialadder(int array[],int n)
        {   
            int i,k=0;
            for (i = 0; i < n; i++) 
                k = 2 * k + array[i];
            return k;
        }
        
        int foojserialadder(int init,int count) 
        {
            static VerilatedContext* contextp = new VerilatedContext;
            static Vjserialadder* jserialadder[1024];
            count--;
            if (init==0) 
            {
                jserialadder[count]=new Vjserialadder{contextp};
                contextp->traceEverOn(true);
            }
            else
            {
                contextp->timeInc(1);
                printf("=============jserialadder : New Iteration===========");
                printf("\nInstance : %d\n",count);
                printf("\nInside foo before eval.....\n");
				printf("clk=%d\n", jserialadder[count] ->clk);
				printf("rst=%d\n", jserialadder[count] ->rst);
				printf("a=%d\n", jserialadder[count] ->a);
				printf("b=%d\n", jserialadder[count] ->b);
				printf("carryin=%d\n", jserialadder[count] ->carryin);
				printf("y=%d\n", jserialadder[count] ->y);
				printf("carryout=%d\n", jserialadder[count] ->carryout);
				printf("isValid=%d\n", jserialadder[count] ->isValid);
				printf("currentsum=%d\n", jserialadder[count] ->currentsum);
				printf("currentcarryout=%d\n", jserialadder[count] ->currentcarryout);
				printf("currentbitcount=%d\n", jserialadder[count] ->currentbitcount);
				jserialadder[count]->clk = arr2intjserialadder(temp_clk, port_clk);
				jserialadder[count]->rst = arr2intjserialadder(temp_rst, port_rst);
				jserialadder[count]->a = arr2intjserialadder(temp_a, port_a);
				jserialadder[count]->b = arr2intjserialadder(temp_b, port_b);
				jserialadder[count]->carryin = arr2intjserialadder(temp_carryin, port_carryin);
				jserialadder[count]->eval();

                printf("\nInside foo after eval.....\n");
				printf("clk=%d\n", jserialadder[count] ->clk);
				printf("rst=%d\n", jserialadder[count] ->rst);
				printf("a=%d\n", jserialadder[count] ->a);
				printf("b=%d\n", jserialadder[count] ->b);
				printf("carryin=%d\n", jserialadder[count] ->carryin);
				printf("y=%d\n", jserialadder[count] ->y);
				printf("carryout=%d\n", jserialadder[count] ->carryout);
				printf("isValid=%d\n", jserialadder[count] ->isValid);
				printf("currentsum=%d\n", jserialadder[count] ->currentsum);
				printf("currentcarryout=%d\n", jserialadder[count] ->currentcarryout);
				printf("currentbitcount=%d\n", jserialadder[count] ->currentbitcount);
				int2arrjserialadder(jserialadder[count] -> y, temp_y, port_y);
				int2arrjserialadder(jserialadder[count] -> carryout, temp_carryout, port_carryout);
				int2arrjserialadder(jserialadder[count] -> isValid, temp_isValid, port_isValid);
				int2arrjserialadder(jserialadder[count] -> currentsum, temp_currentsum, port_currentsum);
				int2arrjserialadder(jserialadder[count] -> currentcarryout, temp_currentcarryout, port_currentcarryout);
				int2arrjserialadder(jserialadder[count] -> currentbitcount, temp_currentbitcount, port_currentbitcount);

            }
            return 0;
        }