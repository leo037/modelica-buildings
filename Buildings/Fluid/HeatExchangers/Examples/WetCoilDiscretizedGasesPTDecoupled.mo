within Buildings.Fluid.HeatExchangers.Examples;
model WetCoilDiscretizedGasesPTDecoupled
  "Model that demonstrates use of a finite volume model of a heat exchanger with condensation"
  extends
    Buildings.Fluid.HeatExchangers.Examples.BaseClasses.WetCoilDiscretized(
   redeclare package Medium2 =
        Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated);
  extends Modelica.Icons.Example;
  // fixme: check dimensionality of system of equations of steady-state hex
  //        and compare with old implementation.
  annotation (
experiment(StopTime=360),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatExchangers/Examples/WetCoilDiscretizedGasesPTDecoupled.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This model is used to test the initialization of the coil model.
There are three instances of the coil model, each having different settings
for the initial conditions.
Each of the coil uses for the medium
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated\">
Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
June 28, 2014, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end WetCoilDiscretizedGasesPTDecoupled;
