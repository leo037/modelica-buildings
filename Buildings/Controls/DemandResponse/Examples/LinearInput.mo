within Buildings.Controls.DemandResponse.Examples;
model LinearInput
  "Demand response client with actual power consumption being linear in the temperature"
  extends
    Buildings.Controls.DemandResponse.Examples.BaseClasses.PartialSimpleTestCase(
      baseLoad(predictionModel=Buildings.Controls.DemandResponse.Types.PredictionModel.WeatherRegression));
  Modelica.Blocks.Sources.Ramp   TOut(
    y(unit="K", displayUnit="degC"),
    height=10,
    duration=1.8144e+06,
    offset=283.15) "Outside temperature"
    annotation (Placement(transformation(extent={{-92,-90},{-72,-70}})));
  Modelica.Blocks.Sources.Constant POffSet(k=1) "Offset for power"
    annotation (Placement(transformation(extent={{-90,-24},{-70,-4}})));
  Modelica.Blocks.Math.Add PCon(k2=0.2) "Consumed power"
    annotation (Placement(transformation(extent={{-60,-30},{-40,-10}})));
  Modelica.Blocks.Math.UnitConversions.To_degC to_degC
    annotation (Placement(transformation(extent={{-20,-70},{0,-50}})));
  Modelica.Blocks.Math.Add err(k2=-1) "Prediction error"
    annotation (Placement(transformation(extent={{70,-40},{90,-20}})));
  Modelica.Blocks.Discrete.Sampler TSam(samplePeriod=tSample)
    "Sampler to turn TOut into a piece-wise constant signal. This makes it easier to verify the results"
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));
  Modelica.Blocks.Continuous.Integrator integrator
    "Integrator to compute energy from power"
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));
equation
  connect(POffSet.y, PCon.u1) annotation (Line(
      points={{-69,-14},{-62,-14}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(baseLoad.PPre, err.u1) annotation (Line(
      points={{61,0},{64,0},{64,-24},{68,-24}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TOut.y, TSam.u) annotation (Line(
      points={{-71,-80},{-62,-80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TSam.y, baseLoad.TOut) annotation (Line(
      points={{-39,-80},{32,-80},{32,-6},{38,-6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(PCon.y, integrator.u) annotation (Line(
      points={{-39,-20},{-2,-20}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(integrator.y, baseLoad.ECon) annotation (Line(
      points={{21,-20},{24,-20},{24,0},{38,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(err.u2, PCon.y) annotation (Line(
      points={{68,-36},{-28,-36},{-28,-20},{-39,-20}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(to_degC.u, TSam.y) annotation (Line(
      points={{-22,-60},{-32,-60},{-32,-80},{-39,-80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(to_degC.y, PCon.u2) annotation (Line(
      points={{1,-60},{12,-60},{12,-40},{-70,-40},{-70,-26},{-62,-26}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (
  experiment(StopTime=1.8144e+06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/DemandResponse/Examples/LinearInput.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This model is identical to 
<a href=\"modelica://Buildings.Controls.DemandResponse.Examples.SineInput\">
Buildings.Controls.DemandResponse.Examples.SineInput</a>,
except that the input <code>client.PCon</code> is linear in the temperature.
</p>
<p>
This model has been added to the library to verify and demonstrate the correct implementation
of the baseline prediction model based on a simple input scenario.
</p>
</html>", revisions="<html>
<ul>
<li>
March 21, 2014 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}), graphics));
end LinearInput;