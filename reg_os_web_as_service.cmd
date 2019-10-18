@echo off
set BasePath="%2"
set addr="http://PC063001:5005/"
set SrvcName="1C:HTTP Interface for RAC"
set BinPath="%1 --urls=%addr% --BasePath=%BasePath%"
set Desctiption="1C HTTP Interface for remote administration"
sc stop %SrvcName%
sc delete %SrvcName%
rem sc create %SrvcName% binPath= %BinPath% start= auto obj= %SrvUserName% password= %SrvUserPwd% displayname= %Desctiption%
sc create %SrvcName% binPath= %BinPath% start= auto displayname= %Desctiption%