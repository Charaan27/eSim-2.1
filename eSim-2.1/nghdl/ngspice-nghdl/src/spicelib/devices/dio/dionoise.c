/**********
Copyright 1990 Regents of the University of California.  All rights reserved.
Author: 1987 Gary W. Ng
Modified by Dietmar Warning 2003
**********/

#include "ngspice/ngspice.h"
#include "diodefs.h"
#include "ngspice/cktdefs.h"
#include "ngspice/iferrmsg.h"
#include "ngspice/noisedef.h"
#include "ngspice/suffix.h"

/*
 * DIOnoise (mode, operation, firstModel, ckt, data, OnDens)
 *     This routine names and evaluates all of the noise sources
 *     associated with diodes.  It starts with the model *firstModel and
 *     traverses all of its instancess.  It then proceeds to any other
 *     models on the linked list.  The total output noise density
 *     generated by all of the diodes is summed with the variable
 *     "OnDens".
 */


int
DIOnoise (int mode, int operation, GENmodel *genmodel, CKTcircuit *ckt, 
          Ndata *data, double *OnDens)
{
    NOISEAN *job = (NOISEAN *) ckt->CKTcurJob;

    DIOmodel *firstModel = (DIOmodel *) genmodel;
    DIOmodel *model;
    DIOinstance *inst;
    double tempOnoise;
    double tempInoise;
    double noizDens[DIONSRCS];
    double lnNdens[DIONSRCS];
    int i;

    /* define the names of the noise sources */

    static char *DIOnNames[DIONSRCS] = {       /* Note that we have to keep the order */
	"_rs",              /* noise due to rs */        /* consistent with thestrchr definitions */
	"_id",              /* noise due to id */        /* in DIOdefs.h */
	"_1overf",          /* flicker (1/f) noise */
	""                  /* total diode noise */
    };

    for (model=firstModel; model != NULL; model=DIOnextModel(model)) {
	for (inst=DIOinstances(model); inst != NULL; inst=DIOnextInstance(inst)) {

	    switch (operation) {

	    case N_OPEN:

		/* see if we have to to produce a summary report */
		/* if so, name all the noise generators */

		if (job->NStpsSm != 0) {
		    switch (mode) {

		    case N_DENS:
			for (i=0; i < DIONSRCS; i++) {
			    NOISE_ADD_OUTVAR(ckt, data, "onoise_%s%s", inst->DIOname, DIOnNames[i]);
			}
			break;

		    case INT_NOIZ:
			for (i=0; i < DIONSRCS; i++) {
			    NOISE_ADD_OUTVAR(ckt, data, "onoise_total_%s%s", inst->DIOname, DIOnNames[i]);
			    NOISE_ADD_OUTVAR(ckt, data, "inoise_total_%s%s", inst->DIOname, DIOnNames[i]);
			}
			break;
		    }
		}
		break;

	    case N_CALC:
		switch (mode) {

		case N_DENS:
		    NevalSrc(&noizDens[DIORSNOIZ],&lnNdens[DIORSNOIZ],
				 ckt,THERMNOISE,inst->DIOposPrimeNode,inst->DIOposNode,
				 inst->DIOtConductance * inst->DIOarea * inst->DIOm);
		    NevalSrc(&noizDens[DIOIDNOIZ],&lnNdens[DIOIDNOIZ],
			         ckt,SHOTNOISE,inst->DIOposPrimeNode, inst->DIOnegNode,
				 *(ckt->CKTstate0 + inst->DIOcurrent));

		    NevalSrc(&noizDens[DIOFLNOIZ], NULL, ckt,
				 N_GAIN,inst->DIOposPrimeNode, inst->DIOnegNode,
				 (double)0.0);
		    noizDens[DIOFLNOIZ] *= model->DIOfNcoef * 
				 exp(model->DIOfNexp *
				 log(MAX(fabs(*(ckt->CKTstate0 + inst->DIOcurrent)/inst->DIOm),N_MINLOG))) /
				 data->freq * inst->DIOm;
		    lnNdens[DIOFLNOIZ] = 
				 log(MAX(noizDens[DIOFLNOIZ],N_MINLOG));

		    noizDens[DIOTOTNOIZ] = noizDens[DIORSNOIZ] +
						    noizDens[DIOIDNOIZ] +
						    noizDens[DIOFLNOIZ];
		    lnNdens[DIOTOTNOIZ] = 
				 log(MAX(noizDens[DIOTOTNOIZ], N_MINLOG));

		    *OnDens += noizDens[DIOTOTNOIZ];

		    if (data->delFreq == 0.0) { 

			/* if we haven't done any previous integration, we need to */
			/* initialize our "history" variables                      */

			for (i=0; i < DIONSRCS; i++) {
			    inst->DIOnVar[LNLSTDENS][i] = lnNdens[i];
			}

			/* clear out our integration variables if it's the first pass */

			if (data->freq == job->NstartFreq) {
			    for (i=0; i < DIONSRCS; i++) {
				inst->DIOnVar[OUTNOIZ][i] = 0.0;
				inst->DIOnVar[INNOIZ][i] = 0.0;
			    }
			}
		    } else {   /* data->delFreq != 0.0 (we have to integrate) */

/* To insure accurracy, we have to integrate each component separately */

			for (i=0; i < DIONSRCS; i++) {
			    if (i != DIOTOTNOIZ) {
				tempOnoise = Nintegrate(noizDens[i], lnNdens[i],
				      inst->DIOnVar[LNLSTDENS][i], data);
				tempInoise = Nintegrate(noizDens[i] * data->GainSqInv ,
				      lnNdens[i] + data->lnGainInv,
				      inst->DIOnVar[LNLSTDENS][i] + data->lnGainInv,
				      data);
				inst->DIOnVar[LNLSTDENS][i] = lnNdens[i];
				data->outNoiz += tempOnoise;
				data->inNoise += tempInoise;
				if (job->NStpsSm != 0) {
				    inst->DIOnVar[OUTNOIZ][i] += tempOnoise;
				    inst->DIOnVar[OUTNOIZ][DIOTOTNOIZ] += tempOnoise;
				    inst->DIOnVar[INNOIZ][i] += tempInoise;
				    inst->DIOnVar[INNOIZ][DIOTOTNOIZ] += tempInoise;
                                }
			    }
			}
		    }
		    if (data->prtSummary) {
			for (i=0; i < DIONSRCS; i++) {     /* print a summary report */
			    data->outpVector[data->outNumber++] = noizDens[i];
			}
		    }
		    break;

		case INT_NOIZ:        /* already calculated, just output */
		    if (job->NStpsSm != 0) {
			for (i=0; i < DIONSRCS; i++) {
			    data->outpVector[data->outNumber++] = inst->DIOnVar[OUTNOIZ][i];
			    data->outpVector[data->outNumber++] = inst->DIOnVar[INNOIZ][i];
			}
		    }    /* if */
		    break;
		}    /* switch (mode) */
		break;

	    case N_CLOSE:
		return (OK);         /* do nothing, the main calling routine will close */
		break;               /* the plots */
	    }    /* switch (operation) */
	}    /* for inst */
    }    /* for model */

return(OK);
}
            

