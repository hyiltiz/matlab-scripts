// compile with:
//      mex kendallTau.c kendl1.c kendl2.c erfcc.c mymath.c nrutil.c

#include "mex.h"
#include "mymath.h"
#include "nrutil.h"
#include <math.h>

void kendl1(float data1[], float data2[], unsigned long n, float *tau, float *z, float *prob);
void kendl2(float **tab, int i, int j, float *tau, float *z, float *prob);

// Notes: This function now takes & returns double inputs/outputs.
// although it converts them to float for calculations
void kendallTau1Double(double pdData1[], double pdData2[], unsigned long n, 
        double *pdTau, double *pdProb) {
 
    float *pfData1, *pfData2, pfTau[1], pfZ[1], pfProb[1];
    unsigned long i;

    // Convert inputs to float
    pfData1=vector(1, n);
    pfData2=vector(1, n);
    for (i=1;i<=n;i++) {
        pfData1[i] = (float) pdData1[i];
        pfData2[i] = (float) pdData2[i];
    }
    
    kendl1(pfData1, pfData2, n, pfTau, pfZ, pfProb);
            
    // Convert outputs to double
    *pdTau     = (double) *pfTau;    
    if (pdProb != NULL)
        *pdProb = (double) *pfProb;
    
    free_vector(pfData1, 1, n);
    free_vector(pfData2, 1, n);
}

void kendallTau2Double(float **pfDataTable, int i, int j,
        double *pdTau, double *pdProb) {
 
    float pfTau[1], pfZ[1], pfProb[1];
    int ki, kj;
    
    kendl2(pfDataTable, i, j, pfTau, pfZ, pfProb);
            
    // Convert outputs to double
    *pdTau     = (double) *pfTau;    
    if (pdProb != NULL)
        *pdProb = (double) *pfProb;
    
    free_matrix(pfDataTable, 1, i, 1, j);
}

void mexFunction( int nlhs, mxArray *plhs[], 
                  int nrhs, const mxArray *prhs[] ) {
    
    // INPUT:
    unsigned long i, j, N, N2;
    mwSize nrows1,ncols1, nrows2, ncols2;
    mxArray *prhs0Sorted[2], *prhs1Sorted[2];
    const mxArray *pArg;

    // LOCAL:
    const unsigned long NMAX = 50;
    const int NBINS = 10;
    int a, b;
    
    double sf = 0, sg = 0;
    double *pdData0, *pdData1; 
    float **pfDataTable = 0;
    double tmp;
    
    // OUTPUT:
    double *pdTau, *pdProb;   
    
    /* --------------- Check inputs ---------------------*/
    if (nrhs != 2)
        mexErrMsgTxt("2 inputs required");
    if (nlhs > 2)  
        mexErrMsgTxt("maximum of 2 outputs allowed");
    
    /// ------------------- data1 ----------
	pArg = prhs[0];
    nrows1 = mxGetM(pArg); ncols1 = mxGetN(pArg);
	if (!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 1 must be a noncomplex matrix of doubles.");
	N = nrows1*ncols1;
    pdData0 = mxGetPr(prhs[0]);
    
    /// ------------------- data2 ----------
	pArg = prhs[1];
    nrows2 = mxGetM(pArg); ncols2 = mxGetN(pArg);
	if (!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 2 must be a noncomplex matrix of doubles.");
	pdData1 = mxGetPr(prhs[1]);
    
    if ((nrows1 != nrows2) || (ncols1 != ncols2))
        mexErrMsgTxt("Inputs 1 and 2 must be the same size.");
        
    /// ---- initialize output variables (pdTau, pdProb ) ----
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    pdTau = mxGetPr(plhs[0]);
    if (nlhs > 1) {
        plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
        pdProb = mxGetPr(plhs[1]);
    } else {
        pdProb = NULL;
    }
    
    if (N < NMAX) {  // Normal Kendall Tau algorithm
        kendallTau1Double(pdData0-1, pdData1-1, N, pdTau, pdProb);
        
    } else {         // Use contingency table for large size arrays (because of O(n^2) behavior)
        pfDataTable = matrix(1, NBINS, 1, NBINS);
        hist2d(pdData0-1, pdData1-1, N, NBINS, NBINS, pfDataTable);
        kendallTau2Double(pfDataTable, NBINS, NBINS, pdTau, pdProb);
    }
    

}
