// compile with:
//    mex pearsonR_v.c pearsn.c erfcc.c betai.c betacf.c gammln.c nrutil.c

#include "nrutil.h"
#include "mex.h"
#include <math.h>

// Notes: This function now takes & returns double inputs/outputs.
// although it converts them to float for calculations
void pearsonsRho_Double(double pdData1[], double pdData2[], unsigned long n, 
        double *pdRho, double *pdProb) {
 
    float *pfData1, *pfData2, pfRho[1], pfZ[1], *pfProb;
    unsigned long i;

    
    if (pdProb == NULL) {
        pfProb = NULL;
    } else {
        pfProb = vector(1, 1);
    }
            
    // Convert inputs to float
    pfData1=vector(1, n);
    pfData2=vector(1, n);
    for (i=1;i<=n;i++) {
        pfData1[i] = (float) pdData1[i];
        pfData2[i] = (float) pdData2[i];
    }
    
    pearsn(pfData1, pfData2, n, pfRho, pfProb, pfZ);
    
    // Convert outputs to double
    *pdRho     = (double) *pfRho;    
    if (pdProb != NULL) {
        *pdProb = (double) *pfProb;
        free_vector(pfProb, 1, 1);
    }
    
    free_vector(pfData1, 1, n);
    free_vector(pfData2, 1, n);
}
        

void pearsonsRho_float(float pfData1[], float pfData2[], unsigned long n, 
        double *pdRho, double *pdProb) {
 
    float pfRho[1], pfZ[1], *pfProb;
    
    if (pdProb == NULL) {
        pfProb = NULL;
    } else {
        pfProb =vector(1, 1);
    }
                
    pearsn(pfData1, pfData2, n, pfRho, pfProb, pfZ);
    
    // Convert outputs to double
    *pdRho     = (double) *pfRho;    
    if (pdProb != NULL) {
        *pdProb = (double) *pfProb;
        free_vector(pfProb, 1, 1);
    }
    
}



void mexFunction( int nlhs, mxArray *plhs[], 
                  int nrhs, const mxArray *prhs[] ) {
    
    // INPUT:
    unsigned long N, nVecs, vi;
    mwSize nrows1,ncols1, nrows2, ncols2;
    mxArray *prhs0Sorted[2], *prhs1Sorted[2];
    const mxArray *pArg;

    // INSIDE:
    double sf = 0, sg = 0;
    double *pdData0, *pdData1;    
    
    // OUTPUT:
    double *pdRho, *pdProb, *pdProb_tmp;   
    int calcPval;
    
    /* --------------- Check inputs ---------------------*/
    if (nrhs != 2)
        mexErrMsgTxt("2 inputs required");
    if (nlhs > 2)  
        mexErrMsgTxt("maximum of 2 outputs allowed");
    
    /// ------------------- data1 ----------
	pArg = prhs[0];
    nrows1 = mxGetM(pArg); ncols1 = mxGetN(pArg);
	if (!(mxIsDouble(pArg) || mxIsClass(pArg, "single")) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 1 must be a noncomplex matrix of singles or doubles.");
	if ((nrows1>1) && (ncols1 > 1)) {
        nVecs = ncols1;
        N = nrows1;
    } else {
        nVecs = 1;
        N = nrows1*ncols1;
    }    
    
    /// ------------------- data2 ----------
	pArg = prhs[1];
    nrows2 = mxGetM(pArg); ncols2 = mxGetN(pArg);
	if (!(mxIsDouble(pArg) || mxIsClass(pArg, "single")) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 2 must be a noncomplex matrix of doubles or singles.");	

    
    if (mxGetClassID(prhs[0]) != mxGetClassID(prhs[1]))
        mexErrMsgTxt("Inputs 1 and 2 must both be the same class.");    
    
    if ((nrows1 != nrows2) || (ncols1 != ncols2))
        mexErrMsgTxt("Inputs 1 and 2 must be the same size.");
         
    
    /// ---- initialize output variables (pdRho, pdProb ) ----
    plhs[0] = mxCreateDoubleMatrix(1, nVecs, mxREAL);
    pdRho = mxGetPr(plhs[0]);
    calcPval = (nlhs > 1);
    if (calcPval) {
        plhs[1] = mxCreateDoubleMatrix(1, nVecs, mxREAL);
        pdProb = mxGetPr(plhs[1]);
    } else {
        pdProb = NULL;
        pdProb_tmp = NULL;
    }
        
    /// -------------------  CALL C FUNCTION 
    
    if (mxIsDouble(pArg)) {
        pdData0 = mxGetPr(prhs[0]);
        pdData1 = mxGetPr(prhs[1]);        
    } else {
        pfData0 = (float*) mxGetData(prhs[0]);
        pfData1 = (float*) mxGetData(prhs[1]);                
        
    }
    
    pearsonsRho_Double(pdData0-1, pdData1-1, N, pdRho, pdProb);    
    pearsonsRho_float(pfData0-1, pfData1-1, N, pdRho, pdProb);
    
    
    if (nVecs == 1) {
        if (mxIsDouble(pArg)) {
            pearsonsRho_Double(pdData0-1, pdData1-1, N, pdRho, pdProb);
        } else {
            pearsonsRho_float(pfData0-1, pfData1-1, N, pdRho, pdProb);
        }
        
    } else {        
        for (vi = 0; vi<nVecs; vi++) {
            if (calcPval) {
                pdProb_tmp = &pdProb[vi];
            }
            if (mxIsDouble(pArg)) {
                pearsonsRho_Double(pdData0-1+(N*vi), pdData1-1+(N*vi), N, &pdRho[vi], pdProb_tmp);            
            } else {
                pearsonsRho_float(pfData0-1+(N*vi), pfData1-1+(N*vi), N, &pdRho[vi], pdProb_tmp);
            }
        }    
        
    }

}





