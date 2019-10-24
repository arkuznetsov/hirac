@echo off
set OscriptWebBinary = "%1"
set addr="%2"
set ContentRoot="%3"
set SrvcName="1C:HTTP Interface for RAC"
set BinPath="%OscriptWebBinary% --RunAsService --urls=%addr% --ContentRoot=%ContentRoot%"
set Desctiption="1C HTTP Interface for remote administration"
sc stop %SrvcName%
sc delete %SrvcName%
sc create %SrvcName% binPath= %BinPath% start= auto displayname= %Desctiption%