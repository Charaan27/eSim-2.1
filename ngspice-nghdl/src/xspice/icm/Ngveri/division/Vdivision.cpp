// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vdivision.h"
#include "Vdivision__Syms.h"

//============================================================
// Constructors

Vdivision::Vdivision(VerilatedContext* _vcontextp__, const char* _vcname__)
    : vlSymsp{new Vdivision__Syms(_vcontextp__, _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , exception{vlSymsp->TOP.exception}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
}

Vdivision::Vdivision(const char* _vcname__)
    : Vdivision(nullptr, _vcname__)
{
}

//============================================================
// Destructor

Vdivision::~Vdivision() {
    delete vlSymsp;
}

//============================================================
// Evaluation loop

void Vdivision___024root___eval_initial(Vdivision___024root* vlSelf);
void Vdivision___024root___eval_settle(Vdivision___024root* vlSelf);
void Vdivision___024root___eval(Vdivision___024root* vlSelf);
QData Vdivision___024root___change_request(Vdivision___024root* vlSelf);
#ifdef VL_DEBUG
void Vdivision___024root___eval_debug_assertions(Vdivision___024root* vlSelf);
#endif  // VL_DEBUG
void Vdivision___024root___final(Vdivision___024root* vlSelf);

static void _eval_initial_loop(Vdivision__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    Vdivision___024root___eval_initial(&(vlSymsp->TOP));
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial loop\n"););
        Vdivision___024root___eval_settle(&(vlSymsp->TOP));
        Vdivision___024root___eval(&(vlSymsp->TOP));
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = Vdivision___024root___change_request(&(vlSymsp->TOP));
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("division.v", 301, "",
                "Verilated model didn't DC converge\n"
                "- See https://verilator.org/warn/DIDNOTCONVERGE");
        } else {
            __Vchange = Vdivision___024root___change_request(&(vlSymsp->TOP));
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vdivision::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vdivision::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vdivision___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        Vdivision___024root___eval(&(vlSymsp->TOP));
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = Vdivision___024root___change_request(&(vlSymsp->TOP));
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("division.v", 301, "",
                "Verilated model didn't converge\n"
                "- See https://verilator.org/warn/DIDNOTCONVERGE");
        } else {
            __Vchange = Vdivision___024root___change_request(&(vlSymsp->TOP));
        }
    } while (VL_UNLIKELY(__Vchange));
}

//============================================================
// Invoke final blocks

void Vdivision::final() {
    Vdivision___024root___final(&(vlSymsp->TOP));
}

//============================================================
// Utilities

VerilatedContext* Vdivision::contextp() const {
    return vlSymsp->_vm_contextp__;
}

const char* Vdivision::name() const {
    return vlSymsp->name();
}
