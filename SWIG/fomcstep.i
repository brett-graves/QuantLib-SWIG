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

#ifndef quantlib_fomc_step_i
#define quantlib_fomc_step_i

%include termstructures.i
%include ratehelpers.i
%include linearalgebra.i
%include calendars.i
%include vectors.i

%{
#include <ql/termstructures/yield/fomcstepcurve.hpp>
using QuantLib::FomcStepCurveConfig;
using QuantLib::FomcStepParametrisation;
using QuantLib::FomcStepFit;
%}

struct FomcStepCurveConfig {
    FomcStepCurveConfig();
    Real horizonYears;
    std::vector<Real> splineKnotsYears;
    Real pathSigmaBp;
    std::vector<Real> turnPriorMeanBp;
    std::vector<Real> turnPriorSdBp;
    std::vector<Real> turnShape;
    Real bandInnerK;
    Real bandWallBp;
    Real spreadStepBp;
    Real spreadCurveBp;
    Real curvatureLambda;
    Integer curveYears;
    Integer tailNodeDays;
    Size maxOuterSteps;
    Real nonlinearTolBp;
};

%shared_ptr(FomcStepParametrisation)
class FomcStepParametrisation {
  public:
    FomcStepParametrisation(const Date& referenceDate,
                            std::vector<Date> meetingDecisions,
                            Calendar calendar,
                            FomcStepCurveConfig config = FomcStepCurveConfig(),
                            bool withEffr = false);
    Size size() const;
    const std::vector<std::string>& names() const;
    const Date& referenceDate() const;
    const Date& switchDate() const;
    const std::vector<Date>& meetingDecisions() const;
    const std::vector<Date>& meetingEffectiveDates() const;
    const std::vector<Date>& businessDays() const;
    const std::vector<Date>& nodeDates() const;
    const std::vector<Date>& spreadKnots() const;
    const FomcStepCurveConfig& config() const;
    bool withEffr() const;
    Size levelIndex() const;
    std::vector<Real> rates(const Array& x, bool effr = false) const;
    std::vector<DiscountFactor> nodeDiscounts(const Array& x, bool effr = false) const;
    Matrix dLogDiscountDx(const Array& x) const;
    const Matrix& penaltyMatrix() const;
    const Array& penaltyOffset() const;
    Array initialGuess(Real overnightBp) const;
    %extend {
        // Parameter blocks as [begin, end) column ranges.
        Size movesBegin() const { return self->movesRange().first; }
        Size movesEnd() const { return self->movesRange().second; }
        Size spreadBegin() const { return self->spreadRange().first; }
        Size spreadEnd() const { return self->spreadRange().second; }
        Size turnsBegin() const { return self->turnsRange().first; }
        Size turnsEnd() const { return self->turnsRange().second; }
        Size splineBegin() const { return self->splineRange().first; }
        Size splineEnd() const { return self->splineRange().second; }
    }
};

%shared_ptr(FomcStepFit)
class FomcStepFit {
  public:
    FomcStepFit(ext::shared_ptr<FomcStepParametrisation> parametrisation,
                std::vector<ext::shared_ptr<RateHelper> > helpers,
                std::vector<std::string> names,
                std::vector<Real> bpValues,
                std::vector<Real> halfWidthsBp,
                std::vector<bool> onEffrCurve,
                std::vector<bool> synthetic,
                const DayCounter& dayCounter);
    void fit(const Array& x0,
             const std::string& loss = "band",
             bool holdSynthetic = false,
             bool reuseJacobian = false);
    void show(const Array& x);
    const ext::shared_ptr<FomcStepParametrisation>& parametrisation() const;
    ext::shared_ptr<YieldTermStructure> sofrCurve() const;
    ext::shared_ptr<YieldTermStructure> effrCurve() const;
    const std::vector<std::string>& targetNames() const;
    const Array& parameters() const;
    const Array& shownParameters() const;
    const Array& residualsBp() const;
    const Matrix& covariance() const;
    const Matrix& dxdq() const;
    const Matrix& dLogDiscountDq() const;
    const Matrix& quoteJacobian() const;
    std::vector<std::string> outsideBand() const;
    Real cost() const;
    Size outerSteps() const;
};

#endif
