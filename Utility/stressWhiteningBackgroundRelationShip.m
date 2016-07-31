function F = stressWhiteningBackgroundRelationShip(parameters,dataColumn)
    F = parameters(1)+parameters(2)*dataColumn+parameters(3)*dataColumn.^2;