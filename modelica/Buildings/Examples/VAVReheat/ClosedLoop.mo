within Buildings.Examples.VAVReheat;
model ClosedLoop "Closed loop model of variable air volume flow system"
  extends Modelica.Icons.Example;
  // fixme package MediumA = Modelica.Media.Air.MoistAir;
  // works package MediumA = Buildings.Media.PerfectGases.MoistAir;
  //package MediumA = Buildings.Media.PerfectGases.MoistAirUnsaturated;
  replaceable package MediumA =
      Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated;
  package MediumW = Buildings.Media.ConstantPropertyLiquidWater
    "Medium model for water";
  constant Real conv=1.2 "Conversion factor for nominal mass flow rate";
  parameter Modelica.SIunits.MassFlowRate m0_flow_cor=3.493*conv
    "Design mass flow rate core";
  parameter Modelica.SIunits.MassFlowRate m0_flow_per1=0.878*conv
    "Design mass flow rate perimeter 1";
  parameter Modelica.SIunits.MassFlowRate m0_flow_per2=0.992*conv
    "Design mass flow rate perimeter 2";
  parameter Modelica.SIunits.MassFlowRate m0_flow_per3=0.760*conv*1.4
    "Design mass flow rate perimeter 3";
  parameter Modelica.SIunits.MassFlowRate m0_flow_per4=1.161*conv
    "Design mass flow rate perimeter 4";
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal=m0_flow_cor +
      m0_flow_per1 + m0_flow_per2 + m0_flow_per3 + m0_flow_per4
    "Nominal mass flow rate";
   parameter Modelica.SIunits.Angle lat=41.98*3.14159/180 "Latitude";
  Fluid.Sources.Outside amb(redeclare package Medium = MediumA, nPorts=2)
    "Ambient conditions"
    annotation (Placement(transformation(extent={{-132,12},{-112,32}})));
  Buildings.Fluid.FixedResistances.FixedResistanceDpM fil(
    m_flow_nominal=m_flow_nominal,
    redeclare package Medium = MediumA,
    dp_nominal=200 + 200 + 100,
    from_dp=false,
    linearized=false) "Filter"
    annotation (Placement(transformation(extent={{60,-50},{80,-30}})));
  Buildings.Fluid.HeatExchangers.DryEffectivenessNTU heaCoi(
    redeclare package Medium1 = MediumA,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=m_flow_nominal,
    allowFlowReversal2=false,
    dp2_nominal=6000,
    m2_flow_nominal=m_flow_nominal*1000*(10 - (-20))/4200/10,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    Q_flow_nominal=m_flow_nominal*1006*(16.7 - 8.5),
    dp1_nominal=0,
    T_a1_nominal=281.65,
    T_a2_nominal=323.15) "Heating coil"
    annotation (Placement(transformation(extent={{98,-56},{118,-36}})));
  Buildings.Fluid.HeatExchangers.WetCoilCounterFlow cooCoi(
    UA_nominal=m_flow_nominal*1000*15/
        Buildings.Fluid.HeatExchangers.BaseClasses.lmtd(
        T_a1=26.2,
        T_b1=12.8,
        T_a2=6,
        T_b2=16),
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    m1_flow_nominal=m_flow_nominal*1000*15/4200/10,
    m2_flow_nominal=m_flow_nominal,
    dp1_nominal=6000,
    dp2_nominal=0) "Cooling coil"
    annotation (Placement(transformation(extent={{210,-36},{190,-56}})));
  Buildings.Fluid.FixedResistances.FixedResistanceDpM dpSupDuc(
    m_flow_nominal=m_flow_nominal,
    dh=1,
    redeclare package Medium = MediumA,
    dp_nominal=20) "Pressure drop for supply duct"
    annotation (Placement(transformation(extent={{420,-50},{440,-30}})));
  Buildings.Fluid.FixedResistances.FixedResistanceDpM dpRetDuc(
    m_flow_nominal=m_flow_nominal,
    use_dh=false,
    dh=1,
    redeclare package Medium = MediumA,
    dp_nominal=20) "Pressure drop for return duct"
    annotation (Placement(transformation(extent={{440,110},{420,130}})));
  Buildings.Fluid.Movers.FlowMachine_y fanSup(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    tau=60,
    dynamicBalance=true,
    redeclare function flowCharacteristic =
        Buildings.Fluid.Movers.BaseClasses.Characteristics.linearFlow (
          V_flow_nominal={m_flow_nominal/1.2*2,0}, dp_nominal={0,850}))
    "Supply air fan"
    annotation (Placement(transformation(extent={{300,-50},{320,-30}})));
  Buildings.Fluid.Movers.FlowMachine_y fanRet(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    tau=60,
    dynamicBalance=true,
    redeclare function flowCharacteristic =
        Buildings.Fluid.Movers.BaseClasses.Characteristics.linearFlow (
          V_flow_nominal=m_flow_nominal/1.2*{2,0}, dp_nominal=1.5*110*{0,2}))
    "Return air fan"
    annotation (Placement(transformation(extent={{310,110},{290,130}})));
  Buildings.Fluid.Sources.FixedBoundary sinHea(
    redeclare package Medium = MediumW,
    p=300000,
    T=318.15,
    nPorts=1) "Sink for heating coil" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={90,-120})));
  Buildings.Fluid.Sources.FixedBoundary sinCoo(
    redeclare package Medium = MediumW,
    p=300000,
    T=285.15,
    nPorts=1) "Sink for cooling coil" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={190,-120})));
  Modelica.Blocks.Routing.RealPassThrough TOut(y(
      final quantity="ThermodynamicTemperature",
      final unit="K",
      displayUnit="degC",
      min=0))
    annotation (Placement(transformation(extent={{-300,138},{-280,158}})));
  inner Modelica.Fluid.System system(
    p_ambient(displayUnit="Pa"),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_small=1E-4*m_flow_nominal)
    annotation (Placement(transformation(extent={{-340,100},{-320,120}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TSup(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{330,-50},{350,-30}})));
  Modelica.Blocks.Sources.Constant TSupSetHea(y(
      final quantity="ThermodynamicTemperature",
      final unit="K",
      displayUnit="degC",
      min=0), k=273.15 + 10) "Supply air temperature setpoint for heating"
    annotation (Placement(transformation(extent={{-100,-170},{-80,-150}})));
  Buildings.Controls.Continuous.LimPID heaCoiCon(
    yMax=1,
    yMin=0,
    Ti=60,
    Td=60,
    initType=Modelica.Blocks.Types.InitPID.InitialState,
    controllerType=Modelica.Blocks.Types.SimpleController.P)
    "Controller for heating coil"
    annotation (Placement(transformation(extent={{0,-170},{20,-150}})));
  Buildings.Controls.Continuous.LimPID cooCoiCon(
    Ti=60,
    reverseAction=true,
    Td=60,
    initType=Modelica.Blocks.Types.InitPID.InitialState,
    yMax=1,
    yMin=0,
    controllerType=Modelica.Blocks.Types.SimpleController.P)
    "Controller for cooling coil"
    annotation (Placement(transformation(extent={{0,-210},{20,-190}})));
  Buildings.Fluid.Sensors.RelativePressure dpRetFan(redeclare package Medium =
        MediumA) "Pressure difference over return fan" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={320,50})));
  Controls.FanVFD conFanSup(xSet_nominal(displayUnit="Pa") = 410, r_N_min=0.0)
    "Controller for fan"
    annotation (Placement(transformation(extent={{240,0},{260,20}})));
  Buildings.Fluid.Sensors.VolumeFlowRate senSupFlo(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal)
    "Sensor for supply fan flow rate"
    annotation (Placement(transformation(extent={{360,-50},{380,-30}})));
  Buildings.Controls.SetPoints.OccupancySchedule occSch(occupancy=3600*{6,19})
    "Occupancy schedule"
    annotation (Placement(transformation(extent={{-318,-220},{-298,-200}})));
  Controls.ModeSelector modeSelector
    annotation (Placement(transformation(extent={{-100,-300},{-80,-280}})));
  Controls.ControlBus controlBus
    annotation (Placement(transformation(extent={{-250,-270},{-230,-250}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TCoiHeaOut(redeclare package
      Medium = MediumA, m_flow_nominal=m_flow_nominal)
    "Heating coil outlet temperature"
    annotation (Placement(transformation(extent={{134,-50},{154,-30}})));
  Buildings.Utilities.Math.Min min(nin=5) "Computes lowest room temperature"
    annotation (Placement(transformation(extent={{1200,440},{1220,460}})));
  Buildings.Utilities.Math.Average ave(nin=5)
    "Compute average of room temperatures"
    annotation (Placement(transformation(extent={{1200,410},{1220,430}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear valCoo(
    redeclare package Medium = MediumW,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    m_flow_nominal=m_flow_nominal*1000*15/4200/10,
    dp_nominal=6000,
    from_dp=true) "Cooling coil valve" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={230,-80})));
  Buildings.Fluid.Sources.FixedBoundary souCoo(
    nPorts=1,
    redeclare package Medium = MediumW,
    p=3E5 + 12000,
    T=285.15) "Source for cooling coil" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={230,-120})));
  Controls.Economizer conEco(
    dT=1,
    k=1,
    Ti=60,
    VOut_flow_min=0.3*m_flow_nominal/1.2) "Controller for economizer"
    annotation (Placement(transformation(extent={{-80,140},{-60,160}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TRet(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal) "Return air temperature sensor"
    annotation (Placement(transformation(extent={{100,110},{80,130}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TMix(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal) "Mixed air temperature sensor"
    annotation (Placement(transformation(extent={{30,-50},{50,-30}})));
  Controls.RoomTemperatureSetpoint TSetRoo
    annotation (Placement(transformation(extent={{-300,-276},{-280,-256}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear valHea(
    redeclare package Medium = MediumW,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    dp_nominal=6000,
    m_flow_nominal=m_flow_nominal*1000*40/4200/10,
    from_dp=true) "Heating coil valve" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={130,-80})));
  Buildings.Fluid.Sources.FixedBoundary souHea(
    nPorts=1,
    redeclare package Medium = MediumW,
    p(displayUnit="Pa") = 300000 + 12000,
    T=318.15) "Source for heating coil" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={130,-120})));
  Buildings.Fluid.Actuators.Dampers.MixingBox eco(
    redeclare package Medium = MediumA,
    mOut_flow_nominal=m_flow_nominal,
    mRec_flow_nominal=m_flow_nominal,
    mExh_flow_nominal=m_flow_nominal,
    dpOut_nominal=10,
    dpRec_nominal=10,
    dpExh_nominal=10) "Economizer"
    annotation (Placement(transformation(extent={{-40,66},{14,12}})));
  Buildings.Fluid.Sensors.VolumeFlowRate VOut1(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal) "Outside air volume flow rate"
    annotation (Placement(transformation(extent={{-80,12},{-60,32}})));
  Controls.DuctStaticPressureSetpoint pSetDuc(
    nin=5,
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    pMin=50) "Duct static pressure setpoint"
    annotation (Placement(transformation(extent={{160,0},{180,20}})));
  Buildings.Examples.VAVReheat.ThermalZones.VAVBranch
                                                    cor(
    redeclare package MediumA = MediumA,
    redeclare package MediumW = MediumW,
    m_flow_nominal=m0_flow_cor,
    VRoo=2698) "Zone for core of buildings (azimuth will be neglected)"
    annotation (Placement(transformation(extent={{550,4},{618,72}})));
  Buildings.Examples.VAVReheat.ThermalZones.VAVBranch
                                                    per1(
    redeclare package MediumA = MediumA,
    redeclare package MediumW = MediumW,
    m_flow_nominal=m0_flow_per1,
    VRoo=568.77) "South-facing thermal zone"
    annotation (Placement(transformation(extent={{688,2},{760,74}})));
  Buildings.Examples.VAVReheat.ThermalZones.VAVBranch
                                                    per2(
    redeclare package MediumA = MediumA,
    redeclare package MediumW = MediumW,
    m_flow_nominal=m0_flow_per2,
    VRoo=360.08) "East-facing thermal zone"
    annotation (Placement(transformation(extent={{826,6},{894,74}})));
  Buildings.Examples.VAVReheat.ThermalZones.VAVBranch
                                                    per3(
    redeclare package MediumA = MediumA,
    redeclare package MediumW = MediumW,
    m_flow_nominal=m0_flow_per3,
    VRoo=568.77) "North-facing thermal zone"
    annotation (Placement(transformation(extent={{966,6},{1034,74}})));
  Buildings.Examples.VAVReheat.ThermalZones.VAVBranch
                                                    per4(
    redeclare package MediumA = MediumA,
    redeclare package MediumW = MediumW,
    m_flow_nominal=m0_flow_per4,
    VRoo=360.08) "West-facing thermal zone"
    annotation (Placement(transformation(extent={{1104,6},{1172,74}})));
  Controls.FanVFD conFanRet(xSet_nominal(displayUnit="m3/s") = m_flow_nominal/
      1.2, r_N_min=0.0) "Controller for fan"
    annotation (Placement(transformation(extent={{240,140},{260,160}})));
  Buildings.Fluid.Sensors.VolumeFlowRate senRetFlo(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal)
    "Sensor for return fan flow rate"
    annotation (Placement(transformation(extent={{380,110},{360,130}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splRetRoo1(
    redeclare package Medium = MediumA,
    m_flow_nominal={m_flow_nominal,m_flow_nominal - m0_flow_cor,m0_flow_cor},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=false,
    dynamicBalance=true,
    linearized=true) "Splitter for room return"
    annotation (Placement(transformation(extent={{600,130},{620,110}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splRetPer1(
    redeclare package Medium = MediumA,
    m_flow_nominal={m0_flow_per1 + m0_flow_per2 + m0_flow_per3 + m0_flow_per4,
        m0_flow_per2 + m0_flow_per3 + m0_flow_per4,m0_flow_per1},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=false,
    dynamicBalance=true,
    linearized=true) "Splitter for room return"
    annotation (Placement(transformation(extent={{738,130},{758,110}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splRetPer2(
    redeclare package Medium = MediumA,
    m_flow_nominal={m0_flow_per2 + m0_flow_per3 + m0_flow_per4,m0_flow_per3 +
        m0_flow_per4,m0_flow_per2},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=false,
    dynamicBalance=true,
    linearized=true) "Splitter for room return"
    annotation (Placement(transformation(extent={{874,130},{894,110}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splRetPer3(
    redeclare package Medium = MediumA,
    m_flow_nominal={m0_flow_per3 + m0_flow_per4,m0_flow_per4,m0_flow_per3},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=false,
    dynamicBalance=true,
    linearized=true) "Splitter for room return"
    annotation (Placement(transformation(extent={{1014,130},{1034,110}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splSupRoo1(
    redeclare package Medium = MediumA,
    m_flow_nominal={m_flow_nominal,m_flow_nominal - m0_flow_cor,m0_flow_cor},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=true,
    linearized=true) "Splitter for room supply"
    annotation (Placement(transformation(extent={{574,-30},{594,-50}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splSupPer1(
    redeclare package Medium = MediumA,
    m_flow_nominal={m0_flow_per1 + m0_flow_per2 + m0_flow_per3 + m0_flow_per4,
        m0_flow_per2 + m0_flow_per3 + m0_flow_per4,m0_flow_per1},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=true,
    linearized=true) "Splitter for room supply"
    annotation (Placement(transformation(extent={{714,-30},{734,-50}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splSupPer2(
    redeclare package Medium = MediumA,
    m_flow_nominal={m0_flow_per2 + m0_flow_per3 + m0_flow_per4,m0_flow_per3 +
        m0_flow_per4,m0_flow_per2},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=true,
    linearized=true) "Splitter for room supply"
    annotation (Placement(transformation(extent={{850,-30},{870,-50}})));
  Buildings.Fluid.FixedResistances.SplitterFixedResistanceDpM splSupPer3(
    redeclare package Medium = MediumA,
    m_flow_nominal={m0_flow_per3 + m0_flow_per4,m0_flow_per4,m0_flow_per3},
    dp_nominal(displayUnit="Pa") = {10,10,10},
    from_dp=true,
    linearized=true) "Splitter for room supply"
    annotation (Placement(transformation(extent={{990,-30},{1010,-50}})));
  Controls.CoolingCoilTemperatureSetpoint TSetCoo "Setpoint for cooling coil"
    annotation (Placement(transformation(extent={{-50,-210},{-30,-190}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        "Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")
    annotation (Placement(transformation(extent={{-390,170},{-370,190}})));
  BoundaryConditions.WeatherData.Bus weaBus "Weather Data Bus"
    annotation (Placement(transformation(extent={{-360,170},{-340,190}})));
  ThermalZones.Floor flo(
    redeclare package Medium = MediumA,
    lat=lat)
    "Model of a floor of the building that is served by this VAV system"
    annotation (Placement(transformation(extent={{800,280},{1128,674}})));
  Modelica.Blocks.Routing.DeMultiplex5 TRooAir
    "Demultiplex for room air temperature"
    annotation (Placement(transformation(extent={{500,80},{520,100}})));
equation
  connect(fil.port_b, heaCoi.port_a1) annotation (Line(
      points={{80,-40},{98,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TSupSetHea.y, heaCoiCon.u_s) annotation (Line(
      points={{-79,-160},{-2,-160}},
      color={0,0,127},
      pattern=LinePattern.None,
      smooth=Smooth.None));
  connect(fanRet.port_a, dpRetFan.port_b) annotation (Line(
      points={{310,120},{320,120},{320,60}},
      color={0,127,255},
      pattern=LinePattern.None,
      smooth=Smooth.None));
  connect(fanSup.port_b, dpRetFan.port_a) annotation (Line(
      points={{320,-40},{320,40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senSupFlo.port_b, dpSupDuc.port_a) annotation (Line(
      points={{380,-40},{420,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(controlBus, modeSelector.cb) annotation (Line(
      points={{-240,-260},{-104,-260},{-104,-286},{-96.8182,-286},{-96.8182,
          -283.182}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(occSch.tNexOcc, controlBus.dTNexOcc) annotation (Line(
      points={{-297,-204},{-240,-204},{-240,-260}},
      color={0,0,127},
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TOut.y, controlBus.TOut) annotation (Line(
      points={{-279,148},{-240,148},{-240,-260}},
      color={0,0,127},
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(occSch.occupied, controlBus.occupied) annotation (Line(
      points={{-297,-216},{-240,-216},{-240,-260}},
      color={255,0,255},
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(min.y, controlBus.TRooMin) annotation (Line(
      points={{1221,450},{1248,450},{1248,-260},{-240,-260}},
      color={0,0,127},
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(ave.y, controlBus.TRooAve) annotation (Line(
      points={{1221,420},{1248,420},{1248,-260},{-240,-260}},
      color={0,0,127},
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(controlBus, conFanSup.controlBus) annotation (Line(
      points={{-240,-260},{280,-260},{280,28},{243,28},{243,18}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(valCoo.port_a, souCoo.ports[1]) annotation (Line(
      points={{230,-90},{230,-110}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TRet.T, conEco.TRet) annotation (Line(
      points={{90,131},{90,172},{-92,172},{-92,157.333},{-81.3333,157.333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TMix.T, conEco.TMix) annotation (Line(
      points={{40,-29},{40,168},{-90,168},{-90,153.333},{-81.3333,153.333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conEco.TSupHeaSet, TSupSetHea.y) annotation (Line(
      points={{-81.3333,145.333},{-220,145.333},{-220,-120},{-10,-120},{-10,
          -160},{-79,-160}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(controlBus, conEco.controlBus) annotation (Line(
      points={{-240,-260},{-240,120},{-76,120},{-76,150.667}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(TSetRoo.controlBus, controlBus) annotation (Line(
      points={{-288,-260},{-240,-260}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(TSup.port_a, fanSup.port_b) annotation (Line(
      points={{330,-40},{320,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TSup.port_b, senSupFlo.port_a) annotation (Line(
      points={{350,-40},{360,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(fil.port_a, TMix.port_b) annotation (Line(
      points={{60,-40},{50,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(conFanSup.y, fanSup.y) annotation (Line(
      points={{261,10},{310,10},{310,-30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(cor.controlBus, controlBus) annotation (Line(
      points={{550,20.32},{550,20},{540,20},{540,-160},{480,-160},{480,-260},{
          -240,-260}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(per1.controlBus, controlBus) annotation (Line(
      points={{688,19.28},{688,18},{674,18},{674,-160},{480,-160},{480,-260},{-240,
          -260}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(per2.controlBus, controlBus) annotation (Line(
      points={{826,22.32},{812,22.32},{812,-160},{480,-160},{480,-260},{-240,
          -260}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(per3.controlBus, controlBus) annotation (Line(
      points={{966,22.32},{950,22.32},{950,-160},{480,-160},{480,-260},{-240,
          -260}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(per4.controlBus, controlBus) annotation (Line(
      points={{1104,22.32},{1092,22.32},{1092,-160},{480,-160},{480,-260},{-240,
          -260}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TCoiHeaOut.T, heaCoiCon.u_m) annotation (Line(
      points={{144,-29},{144,-20},{160,-20},{160,-180},{10,-180},{10,-172}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(souHea.ports[1], valHea.port_a) annotation (Line(
      points={{130,-110},{130,-90}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(heaCoiCon.y, valHea.y) annotation (Line(
      points={{21,-160},{108,-160},{108,-80},{122,-80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(valHea.port_b, heaCoi.port_a2) annotation (Line(
      points={{130,-70},{130,-52},{118,-52}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(heaCoi.port_b2, sinHea.ports[1]) annotation (Line(
      points={{98,-52},{90,-52},{90,-110}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(cooCoiCon.y, valCoo.y) annotation (Line(
      points={{21,-200},{210,-200},{210,-80},{222,-80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conEco.yOA, eco.y) annotation (Line(
      points={{-59.3333,152},{-48,152},{-48,-8},{-13,-8},{-13,6.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(eco.port_Exh, amb.ports[1]) annotation (Line(
      points={{-40,55.2},{-100,55.2},{-100,24},{-112,24}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(amb.ports[2], VOut1.port_a) annotation (Line(
      points={{-112,20},{-96,20},{-96,22},{-80,22}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(VOut1.port_b, eco.port_Out) annotation (Line(
      points={{-60,22},{-50,22},{-50,22.8},{-40,22.8}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(dpRetFan.p_rel, conFanSup.u_m) annotation (Line(
      points={{311,50},{290,50},{290,-10},{250,-10},{250,-2}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(eco.port_Sup, TMix.port_a) annotation (Line(
      points={{14,22.8},{24,22.8},{24,-40},{30,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(pSetDuc.y, conFanSup.u) annotation (Line(
      points={{181,10},{238,10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(cor.yDam, pSetDuc.u[1]) annotation (Line(
      points={{620.267,26.6667},{624,26.6667},{624,190},{140,190},{140,8.4},{
          158,8.4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(per1.yDam, pSetDuc.u[2]) annotation (Line(
      points={{762.4,26},{774,26},{774,190},{140,190},{140,9.2},{158,9.2}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(per2.yDam, pSetDuc.u[3]) annotation (Line(
      points={{896.267,28.6667},{916,28.6667},{916,190},{140,190},{140,10},{158,
          10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(per3.yDam, pSetDuc.u[4]) annotation (Line(
      points={{1036.27,28.6667},{1060,28.6667},{1060,190},{140,190},{140,10.8},
          {158,10.8}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(per4.yDam, pSetDuc.u[5]) annotation (Line(
      points={{1174.27,28.6667},{1196,28.6667},{1196,190},{140,190},{140,11.6},
          {158,11.6}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(heaCoi.port_b1, TCoiHeaOut.port_a) annotation (Line(
      points={{118,-40},{134,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(controlBus, conFanRet.controlBus) annotation (Line(
      points={{-240,-260},{280,-260},{280,168},{243,168},{243,158}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(senSupFlo.V_flow, conFanRet.u) annotation (Line(
      points={{370,-29},{370,90},{200,90},{200,150},{238,150}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(senRetFlo.port_b, fanRet.port_a) annotation (Line(
      points={{360,120},{310,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senRetFlo.V_flow, conFanRet.u_m) annotation (Line(
      points={{370,131},{370,134},{250,134},{250,138}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(conFanRet.y, fanRet.y) annotation (Line(
      points={{261,150},{300,150},{300,130}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(dpRetDuc.port_b, senRetFlo.port_a) annotation (Line(
      points={{420,120},{380,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TRet.port_b, eco.port_Ret) annotation (Line(
      points={{80,120},{24,120},{24,54},{14,54},{14,55.2}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TRet.port_a, fanRet.port_b) annotation (Line(
      points={{100,120},{290,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetRoo1.port_1, dpRetDuc.port_a) annotation (Line(
      points={{600,120},{440,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer3.port_1, splRetPer2.port_2) annotation (Line(
      points={{1014,120},{894,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer2.port_1, splRetPer1.port_2) annotation (Line(
      points={{874,120},{758,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer1.port_1, splRetRoo1.port_2) annotation (Line(
      points={{738,120},{620,120}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(dpSupDuc.port_b, splSupRoo1.port_1) annotation (Line(
      points={{440,-40},{574,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupRoo1.port_3, cor.port_a) annotation (Line(
      points={{584,-30},{584,20.7733}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupRoo1.port_2, splSupPer1.port_1) annotation (Line(
      points={{594,-40},{714,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupPer1.port_3, per1.port_a) annotation (Line(
      points={{724,-30},{724,19.76}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupPer1.port_2, splSupPer2.port_1) annotation (Line(
      points={{734,-40},{850,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupPer2.port_3, per2.port_a) annotation (Line(
      points={{860,-30},{860,22.7733}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupPer2.port_2, splSupPer3.port_1) annotation (Line(
      points={{870,-40},{990,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupPer3.port_3, per3.port_a) annotation (Line(
      points={{1000,-30},{1000,22.7733}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splSupPer3.port_2, per4.port_a) annotation (Line(
      points={{1010,-40},{1138,-40},{1138,22.7733}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TCoiHeaOut.port_b, cooCoi.port_a2) annotation (Line(
      points={{154,-40},{190,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(valCoo.port_b, cooCoi.port_a1) annotation (Line(
      points={{230,-70},{230,-52},{210,-52}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(cooCoi.port_b1, sinCoo.ports[1]) annotation (Line(
      points={{190,-52},{188,-52},{188,-110},{190,-110}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TSetCoo.TSet, cooCoiCon.u_s) annotation (Line(
      points={{-29,-200},{-2,-200}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TSetCoo.TSet, conEco.TSupCooSet) annotation (Line(
      points={{-29,-200},{-20,-200},{-20,-140},{-200,-140},{-200,141.333},{
          -81.3333,141.333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TSupSetHea.y, TSetCoo.TSetHea) annotation (Line(
      points={{-79,-160},{-60,-160},{-60,-200},{-52,-200}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(modeSelector.cb, TSetCoo.controlBus) annotation (Line(
      points={{-96.8182,-283.182},{-104,-286},{-104,-208},{-41.8,-208}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(conEco.VOut_flow, VOut1.V_flow) annotation (Line(
      points={{-81.3333,149.333},{-90,149.333},{-90,80},{-70,80},{-70,33}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-370,180},{-350,180}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(weaBus.TDryBul, TOut.u) annotation (Line(
      points={{-350,180},{-326,180},{-326,148},{-302,148}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(amb.weaBus, weaBus) annotation (Line(
      points={{-132,22.2},{-350,22.2},{-350,180}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(weaBus.TDryBul, pSetDuc.TOut) annotation (Line(
      points={{-350,180},{150,180},{150,18},{158,18}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(cor.port_b, flo.portsCor[1]) annotation (Line(
      points={{584,72},{586,72},{586,252},{784,252},{784,364},{918.08,364},{
          918.08,375.873}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetRoo1.port_3, flo.portsCor[2]) annotation (Line(
      points={{610,130},{610,242},{792,242},{792,354},{928,354},{928,375.873},{
          931.2,375.873}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(per1.port_b, flo.portsPer1[1]) annotation (Line(
      points={{724,74},{724,228},{918.08,228},{918.08,323.34}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer1.port_3, flo.portsPer1[2]) annotation (Line(
      points={{748,130},{750,130},{750,224},{934,224},{934,323.34},{931.2,
          323.34}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(per2.port_b, flo.portsPer2[1]) annotation (Line(
      points={{860,74},{860,218},{1078,218},{1078,369.307},{1078.14,369.307}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer2.port_3, flo.portsPer2[2]) annotation (Line(
      points={{884,130},{882,130},{882,212},{1091.26,212},{1091.26,369.307}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(per3.port_b, flo.portsPer3[1]) annotation (Line(
      points={{1000,74},{1002,74},{1002,412},{918.08,412},{918.08,428.407}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer3.port_3, flo.portsPer3[2]) annotation (Line(
      points={{1024,130},{1024,418},{931.2,418},{931.2,428.407}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(per4.port_b, flo.portsPer4[1]) annotation (Line(
      points={{1138,74},{1140,74},{1140,254},{839.36,254},{839.36,375.873}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(splRetPer3.port_2, flo.portsPer4[2]) annotation (Line(
      points={{1034,120},{1130,120},{1130,242},{852.48,242},{852.48,375.873}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(weaBus, flo.weaBus) annotation (Line(
      points={{-350,180},{-348,180},{-348,477},{1003.36,477}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(flo.TRooAir, min.u) annotation (Line(
      points={{1121.44,450.733},{1164.7,450.733},{1164.7,450},{1198,450}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(flo.TRooAir, ave.u) annotation (Line(
      points={{1121.44,450.733},{1166,450.733},{1166,420},{1198,420}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TRooAir.y1[1], per1.TRoo) annotation (Line(
      points={{521,98},{660,98},{660,50},{683.2,50}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TRooAir.y2[1], per2.TRoo) annotation (Line(
      points={{521,94},{808,94},{808,51.3333},{821.467,51.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TRooAir.y3[1], per3.TRoo) annotation (Line(
      points={{521,90},{950,90},{950,51.3333},{961.467,51.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TRooAir.y4[1], per4.TRoo) annotation (Line(
      points={{521,86},{1088,86},{1088,51.3333},{1099.47,51.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TRooAir.y5[1], cor.TRoo) annotation (Line(
      points={{521,82},{530,82},{530,49.3333},{545.467,49.3333}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TRooAir.u, flo.TRooAir) annotation (Line(
      points={{498,90},{478,90},{478,500},{1162,500},{1162,450.733},{1121.44,
          450.733}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TSup.T, cooCoiCon.u_m) annotation (Line(
      points={{340,-29},{340,-20},{354,-20},{354,-220},{10,-220},{10,-212}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(cooCoi.port_b2, fanSup.port_a) annotation (Line(
      points={{210,-40},{300,-40}},
      color={0,127,255},
      smooth=Smooth.None));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-400,-400},{
            1400,600}}), graphics),
    Documentation(info="<html>
<p>
This model consist of an HVAC system, a building envelope model and a model for air flow through building leakage and through open doors.
</p>
<p>
The HVAC system is a variable air volume (VAV) flow system with economizer and a heating and cooling coil in the air handler unit. There is also a reheat coil and an air damper in each of the five zone inlet branches. The control is an implementation of the control sequence <i>VAV 2A2-21232</i> of the Sequences of Operation for Common HVAC Systems (ASHRAE, 2006). In this control sequence, the supply fan speed is regulated based on the duct static pressure. The return fan controller tracks the supply fan air flow rate reduced by a fixed offset. The duct static pressure is adjusted so that at least one VAV damper is 90% open. The economizer dampers are modulated to track the setpoint for the mixed air dry bulb temperature. Priority is given to maintain a minimum outside air volume flow rate. In each zone, the VAV damper is adjusted to meet the room temperature setpoint for cooling, or fully opened during heating. The room temperature setpoint for heating is tracked by varying the water flow rate through the reheat coil. There is also a finite state machine that transitions the mode of operation of the HVAC system between the modes <i>occupied</i>, <i>unoccupied off</i>, <i>unoccupied night set back</i>, <i>unoccupied warm-up</i> and <i>unoccupied pre-cool</i>. In the VAV model, all air flows are computed based on the duct static pressure distribution and the performance curves of the fans. Local loop control is implemented using proportional and proportional-integral controllers, while the supervisory control is implemented using a finite state machine.
</p>
<p>
To model the heat transfer through the building envelope, a model of five interconnected rooms has been implemented, using the thermal room model 
<a href=\"modelica://Buildings.RoomsBeta.MixedAir\">
Buildings.RoomsBeta.MixedAir</a>. 
The five room model is representative of one floor of the new construction medium office building for Chicago, IL, as described in the set of DOE Commercial Building Benchmarks (Deru et al, 2009). There are four perimeter zones and one core zone. The envelope thermal properties meet ASHRAE Standard 90.1-2004.
</p>
<p>
Each thermal zone can have air flow from the HVAC system, through leakages of the building envelope (except for the core zone) and through bi-directional air exchange through open doors that connect adjacent zones. The bi-directional air exchange is modeled based on the differences in static pressure between adjacent rooms at a reference height plus the difference in static pressure across the door height as a function of the difference in air density.
</p>
<h4>References</h4>
<p>
ASHRAE.
<i>Sequences of Operation for Common HVAC Systems</i>.
ASHRAE, Atlanta, GA, 2006.
</p>
<p>
Deru M., K. Field, D. Studer, K. Benne, B. Griffith, P. Torcellini,
 M. Halverson, D. Winiarski, B. Liu, M. Rosenberg, J. Huang, M. Yazdanian, and D. Crawley.
<i>DOE commercial building research benchmarks for commercial buildings</i>.
Technical report, U.S. Department of Energy, Energy Efficiency and
Renewable Energy, Office of Building Technologies, Washington, DC, 2009.
</p>
</html>"),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Examples/VAVReheat/ClosedLoop.mos"
        "Simulate and plot"),
    experiment(
      StopTime=172800,
      Tolerance=1e-006,
      Algorithm="radau"));
end ClosedLoop;