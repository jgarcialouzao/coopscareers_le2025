

# Data access
This research uses anonymized administrative data from the Muestra Continua de Vidas Laborales con Datos Fiscales (MCVL) with the permission of Spain's Dirección General de Ordenación de la Seguridad Social.
Unfortunately, the data is not publicly available. Therefore, we will provide information about the application process and the files needed to replicate the results.

Full information on the MCVL can be found at https://www.seg-social.es/wps/portal/wss/internet/EstadisticasPresupuestosEstudios/Estadisticas/EST211

The application process to obtain MCVL data requires the completion of several forms (in Spanish) that are available from https://www.seg-social.es/wps/wcm/connect/wss/a5e35e4b-7622-4b6a-9205-1129c8b6d95e/FormMCVL20220124c.pdf?MOD=AJPERES
The forms ask for the researcher(s) and project information, as well as the version of the MCVL and the required years. 
There are two versions of the MCVL, with and without fiscal data. This research requires access to the version with fiscal data (con Datos Fiscales in Spanish).
Once the forms have been completed and signed, they should be sent to mcvl.dgoss-sscc@seg-social.es

The Social Security administration evaluates the request and, if positive, the data are shared with the researchers.


# Replication files
The full set of results can be obtained by running the `0_Master_File.do` program. This program includes the following sub-programs:

## Data preparation
* `1_read_MCVL.do`          - opens raw MCVL files and transforms them in Stata format 
* `2_code_panels.do`        - runs a sequence of do.files that create different panels [firms, workers, jobs, wages] that will be merged together 
* `3_data_prep.do`          - prepares the data for the analysis; requires associated ado files: `sectorhom.do` `provtoreg.do` `censoredtobit_CHK.ado`

## Main text 
* `Reg_Baseline.do` 				            - produces benchmark wage results as well as IV estimates and Oster bound exercise
* `Reg_Mobility.do`      				        - produces mobility models
* `Reg_WageMobility_CoopIncidence.do`   - estimates the wage gap and mobility by the incidence of cooperative time
* `Reg_Returns2Exp.do`                  - produces wage returns to experience [including figure for catch-up rate]
* `Reg_Promotions2Exp.do`               - produces promotion returns to experience

## Regular appendix
* `Desc_FirstJob.do` and `Desc_PooledSample.do`  - generate results in the descriptive statatistics table
* `Reg_Baseline_Heterogeneity.do`                - wage effects by sub-groups 
* `Reg_JobLadder.do`                             - persistence of cooperative employer


## Online appendix


