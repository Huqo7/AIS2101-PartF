Data = readtable("airfoilSelfNoise/airfoil_self_noise.dat");

TF = ismissing(Data);

cv = cvpartition(size(Data, 1), 'HoldOut',0.3);
i = cv.test;

DataTrain = Data(~i,:);
DataTest = Data(i,:);

Output = DataTrain.Var6;
Input = table(DataTrain.Var1,DataTrain.Var2,DataTrain.Var3,DataTrain.Var4,DataTrain.Var5);

fis = genfis(Input{:,:},Output)

rng('default')

[in, out, rule] = getTunableSettings(fis);
opt = tunefisOptions;
opt.UseParallel = true;
opt.Method = "particleswarm";
opt.OptimizationType = "learning";

fisOut = tunefis(fis, [in;out], Input{:,:}, Output, opt);

TestInput = table(DataTest.Var1,DataTest.Var2,DataTest.Var3,DataTest.Var4,DataTest.Var5);
TestOutput = DataTest.Var6;

TunedOut = evalfis(fisOut, TestInput{:,:})

fig1 = figure(1);
plot([TestOutput, TunedOut])
legend("Expected output", "Tuned Output")