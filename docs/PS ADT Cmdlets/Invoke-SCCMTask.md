Invoke-SCCMTask
===============

SYNOPSIS
--------

Triggers SCCM to invoke the requested schedule task id.

SYNTAX
------

```powershell
Invoke-SCCMTask [-ScheduleID] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Triggers SCCM to invoke the requested schedule task id.

PARAMETERS
----------

### -ScheduleID

**Type**: `<String>`

Name of the schedule id to trigger.

Options: HardwareInventory, SoftwareInventory, HeartbeatDiscovery,
SoftwareInventoryFileCollection, RequestMachinePolicy,
EvaluateMachinePolicy,

LocationServicesCleanup, SoftwareMeteringReport, SourceUpdate,
PolicyAgentCleanup, RequestMachinePolicy2, CertificateMaintenance,
PeerDistributionPointStatus,

PeerDistributionPointProvisioning, ComplianceIntervalEnforcement,
SoftwareUpdatesAgentAssignmentEvaluation, UploadStateMessage,
StateMessageManager,

SoftwareUpdatesScan, AMTProvisionCycle, UpdateStorePolicy,
StateSystemBulkSend, ApplicationManagerPolicyAction,
PowerManagementStartSummarizer

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Invoke-SCCMTask 'SoftwareUpdatesScan'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Invoke-SCCMTask
```
