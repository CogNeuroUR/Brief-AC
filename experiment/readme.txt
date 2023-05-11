# OV: created on 11.08.21
Derived from https://github.com/CogNeuroUR/ASF-examples

Steps:
1) Create masks for target stimuli by calling:
    >> createMasks_acrossPics
2) Create stimulus definition files by calling:
    >> createStimDefs
3) Create Trial Definition (TRD) file by calling:
    >> makeTRDMasCat(id_subject, id_session, 'Experiment name')
4) Run experiment by calling:
    >> runFastAC(id_subject, id_session, 'Experiment name')
