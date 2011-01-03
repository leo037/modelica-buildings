within Buildings.Utilities.Psychrometrics.Functions;
function TDewPoi_pW_amb
  "Function to compute the dew point temperature of moist air for a given water vapor partial pressure"
  extends Buildings.Utilities.Psychrometrics.Functions.BaseClasses.pW_TDewPoi_amb;

  input Modelica.SIunits.Pressure p_w "Water vapor partial pressure";
  output Modelica.SIunits.Temperature T "Dew point temperature";

algorithm
  T := (Modelica.Math.log(p_w) - a1)/a2;
  annotation (
    inverse(p_w=pW_TDewPoi_amb(T)),
    derivative=BaseClasses.der_TDewPoi_pW_amb,
    Documentation(info="<html>
<p>
Dew point temperature calculation for moist air between <i>0 degC</i> and <i>30 degC</i>
with partial pressure of water vapor as an input.
</p>
<p>
The correlation used in this model is valid for dew point temperatures between 
<tt>0 degC</tt> and <tt>30 degC</tt>. It is an approximation to the correlation from 2005
ASHRAE Handbook, p. 6.2, which is valid in a wider range of temperatures and implemented
in
<a href=\"modelica:Buildings.Utilities.Psychrometrics.Functions.pW_TDewPoi\">
Buildings.Utilities.Psychrometrics.Functions.pW_TDewPoi</a>.
The approximation error of this simplified function is below 5% for a 
temperature of <tt>0 degC</tt> to <tt>30 degC</tt>.
The benefit of this simpler function is that it can be inverted analytically,
whereas the other function requires a numerical solution.
</p>
</html>", revisions="<html>
<ul>
<li>
May 21, 2010 by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics),
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,
            100}}), graphics));
end TDewPoi_pW_amb;