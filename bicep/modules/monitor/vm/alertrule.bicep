//az deployment group create --resource-group <resource-group-name> --template-file <path-to-bicep> --params <path to params.json>
// multi resource support document - https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric-near-real-time#metrics-and-dimensions-supported

param actionGroupName string = 'oncallrj'
param location string = 'global'
param region array
var resourcetype = 'microsoft.compute/virtualmachines'


var actionGroupEmail = 'ritikaj@netapp.com'




resource supportTeamActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: location
  properties: {
    enabled: true
    groupShortName: actionGroupName
    emailReceivers: [
      {
        name: actionGroupName
        emailAddress: actionGroupEmail
        useCommonAlertSchema: false
      }
    ]
  }
}

// iterating over the regions parama and creating alert rule per region 
resource vmmetricalert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for region in region: {
  name: '${region}-rjvmrule'
  location: location
  tags: {
    name: '${region}-vmtestalertrule'
    owner: 'ritikaj@netapp.com'
  }
  properties: {
    actions: [
      {
        actionGroupId: supportTeamActionGroup.id
        webHookProperties: {}
      }
    ]
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
  allOf: [
    {
      metricName: 'VmAvailabilityMetric'
      metricNamespace: 'microsoft.compute/virtualmachines'
      name: 'Metric1'
      skipMetricValidation: false
      timeAggregation: 'Average'
      criterionType: 'StaticThresholdCriterion'
      operator: 'LessThan'
      threshold: 1
    }
  ]
    }
    description: 'test alert created through bicep to check health of all vm resources in a region'
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      subscription().id
    ]
    severity: 4
    targetResourceRegion: region
    targetResourceType: resourcetype
    windowSize: 'PT5M'
  }
}]

