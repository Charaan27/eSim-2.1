// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VCOUNTER64BIT__SYMS_H_
#define VERILATED_VCOUNTER64BIT__SYMS_H_  // guard

#include "verilated_heavy.h"

// INCLUDE MODEL CLASS

#include "Vcounter64bit.h"

// INCLUDE MODULE CLASSES
#include "Vcounter64bit___024root.h"

// SYMS CLASS (contains all model state)
class Vcounter64bit__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vcounter64bit* const __Vm_modelp;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vcounter64bit___024root        TOP;

    // CONSTRUCTORS
    Vcounter64bit__Syms(VerilatedContext* contextp, const char* namep, Vcounter64bit* modelp);
    ~Vcounter64bit__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
