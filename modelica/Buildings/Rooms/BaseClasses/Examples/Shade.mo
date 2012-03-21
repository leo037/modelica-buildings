within Buildings.Rooms.BaseClasses.Examples;
model Shade "Test model for the Shade model"
  import Buildings;
  extends Modelica.Icons.Example;

  Buildings.Rooms.BaseClasses.Shade sha[3](final conPar=conPar) "Shade model"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    filNam="Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.BoundaryConditions.SolarIrradiation.DirectTiltedSurface HDirTil(
    lat=weaDat.lat,
    til=Buildings.HeatTransfer.Types.Tilt.Wall,
    azi=Buildings.HeatTransfer.Types.Azimuth.S) "Direct solar irradiation"
    annotation (Placement(transformation(extent={{-20,60},{0,80}})));
  Modelica.Blocks.Routing.Replicator H(nout=3) "Replicator"
    annotation (Placement(transformation(extent={{20,60},{40,80}})));
  Modelica.Blocks.Routing.Replicator incAng(nout=3) "Replicator"
    annotation (Placement(transformation(extent={{20,20},{40,40}})));
  parameter Buildings.Rooms.BaseClasses.ParameterConstructionWithWindow conPar[3](
    each til=Buildings.HeatTransfer.Types.Tilt.Wall,
    each azi=Buildings.HeatTransfer.Types.Azimuth.S,
    each A=20,
    each hWin=1.5,
    each wWin=2,
    each glaSys=glaSys,
    ove(
      gap={0.1, 0, 0},
      dep={1, 0, 0},
      w = {2.2, 0, 0}),
    sidFin(
      h = {0, 1.8, 0},
      dep={0, 1, 0},
      gap={0, 0.1, 0}),
    redeclare
      Buildings.HeatTransfer.Data.OpaqueConstructions.Insulation100Concrete200
      layers) "Construction parameters"
    annotation (Placement(transformation(extent={{-40,-80},{-20,-60}})));
  parameter Buildings.HeatTransfer.Data.GlazingSystems.DoubleClearAir13Clear glaSys
    "Glazing system"
    annotation (Placement(transformation(extent={{-80,-80},{-60,-60}})));
equation
  connect(weaDat.weaBus, sha[1].weaBus) annotation (Line(
      points={{-40,5.82867e-16},{-30,5.82867e-16},{-30,6.10623e-16},{60,
          6.10623e-16}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(weaDat.weaBus, sha[2].weaBus) annotation (Line(
      points={{-40,5.82867e-16},{-30,5.82867e-16},{-30,6.10623e-16},{60,
          6.10623e-16}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(weaDat.weaBus, sha[3].weaBus) annotation (Line(
      points={{-40,5.82867e-16},{-30,5.82867e-16},{-30,6.10623e-16},{60,
          6.10623e-16}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(HDirTil.weaBus, weaDat.weaBus) annotation (Line(
      points={{-20,70},{-30,70},{-30,5.82867e-16},{-40,5.82867e-16}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(HDirTil.H, H.u) annotation (Line(
      points={{1,70},{18,70}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(HDirTil.inc, incAng.u) annotation (Line(
      points={{1,66},{10,66},{10,30},{18,30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(incAng.y,sha. incAng) annotation (Line(
      points={{41,30},{48,30},{48,-6},{58,-6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(H.y,sha. HDirTilUns) annotation (Line(
      points={{41,70},{50,70},{50,6},{58,6}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(graphics),
              __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Rooms/BaseClasses/Examples/Shade.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This model tests window overhang and side fins. There are three instances of <code>sha</code>.
The first instance models an overhang, the second models side fins and the third has neither an overhang
nor a side fin.
</p>
</html>", revisions="<html>
<ul>
<li>
March 6, 2012, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"));
end Shade;