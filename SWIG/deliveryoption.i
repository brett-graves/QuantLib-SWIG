/*
 Copyright (C) 2026 Brett Graves

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it
 under the terms of the QuantLib license.  You should have received a
 copy of the license along with this program; if not, please email
 <quantlib-dev@lists.sf.net>. The license is also available online at
 <https://www.quantlib.org/license.shtml>.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

#ifndef quantlib_delivery_option_i
#define quantlib_delivery_option_i

%include types.i
%include vectors.i

%{
#include <ql/pricingengines/bond/deliveryoptionlineskernel.hpp>
#include <numpy/arrayobject.h>
using QuantLib::DeliveryOptionLinesKernel;
%}

// Results come back as flat numpy arrays (one memcpy); the caller reshapes
// the levels-by-bonds blocks.
%typemap(out) std::vector<Real> DeliveryOptionLinesKernel::values,
              std::vector<Real> DeliveryOptionLinesKernel::ctdProbabilities,
              std::vector<Real> DeliveryOptionLinesKernel::sensitivities {
    npy_intp dims[1] = { static_cast<npy_intp>($1.size()) };
    $result = PyArray_SimpleNew(1, dims, NPY_DOUBLE);
    if ($result && $1.size() > 0) {
        memcpy(PyArray_DATA((PyArrayObject*)$result), $1.data(),
               $1.size() * sizeof(double));
    }
}

// Inputs accept any float sequence; numpy arrays are copied in one memcpy.
%typemap(in) const std::vector<Real>& DO_NUMPY_IN (std::vector<Real> temp) {
    PyArrayObject* array = (PyArrayObject*)PyArray_FROMANY(
        $input, NPY_DOUBLE, 1, 1, NPY_ARRAY_IN_ARRAY | NPY_ARRAY_FORCECAST);
    if (!array)
        SWIG_fail;
    const double* data = static_cast<const double*>(PyArray_DATA(array));
    temp.assign(data, data + PyArray_SIZE(array));
    Py_DECREF(array);
    $1 = &temp;
}
%typemap(freearg) const std::vector<Real>& DO_NUMPY_IN "";
%typemap(typecheck, precedence=SWIG_TYPECHECK_DOUBLE_ARRAY) const std::vector<Real>& DO_NUMPY_IN {
    $1 = PySequence_Check($input) || PyArray_Check($input) ? 1 : 0;
}
%apply const std::vector<Real>& DO_NUMPY_IN {
    const std::vector<Real>& beta, const std::vector<Real>& factor1,
    const std::vector<Real>& factor2, const std::vector<Real>& conversion,
    const std::vector<Real>& adjustment, const std::vector<Real>& derivativeShift,
    const std::vector<Real>& gridLower, const std::vector<Real>& prices,
    const std::vector<Real>& slopes, const std::vector<Real>& curvatures,
    const std::vector<Real>& factor1Edges, const std::vector<Real>& factor2Nodes,
    const std::vector<Real>& factor2Weights, const std::vector<Real>& levels
};


class DeliveryOptionLinesKernel {
  public:
    DeliveryOptionLinesKernel(const std::vector<Real>& beta,
                              const std::vector<Real>& factor1,
                              const std::vector<Real>& factor2,
                              const std::vector<Real>& conversion,
                              const std::vector<Real>& adjustment,
                              const std::vector<Real>& derivativeShift,
                              const std::vector<Real>& gridLower,
                              Real gridStep,
                              const std::vector<Size>& gridLength,
                              const std::vector<Real>& prices,
                              const std::vector<Real>& slopes,
                              const std::vector<Real>& curvatures,
                              const std::vector<Real>& factor1Edges,
                              const std::vector<Real>& factor2Nodes,
                              const std::vector<Real>& factor2Weights,
                              Real tieTolerance);
    void evaluate(const std::vector<Real>& levels, bool withSensitivities);
    Size bonds() const;
    std::vector<Real> values() const;
    std::vector<Real> ctdProbabilities() const;
    std::vector<Real> sensitivities() const;
};

%clear const std::vector<Real>& beta, const std::vector<Real>& factor1,
    const std::vector<Real>& factor2, const std::vector<Real>& conversion,
    const std::vector<Real>& adjustment, const std::vector<Real>& derivativeShift,
    const std::vector<Real>& gridLower, const std::vector<Real>& prices,
    const std::vector<Real>& slopes, const std::vector<Real>& curvatures,
    const std::vector<Real>& factor1Edges, const std::vector<Real>& factor2Nodes,
    const std::vector<Real>& factor2Weights, const std::vector<Real>& levels;

#endif
