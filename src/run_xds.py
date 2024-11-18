import datetime
import os
import pathlib
import shutil
import subprocess
import tempfile
import tomllib
from textwrap import dedent
from typing import Annotated

import typer
from pydantic import BaseModel

app = typer.Typer()


class XdsConfig(BaseModel):
    starting_angle: float

    def to_xds_inp(self, outfile: pathlib.Path):
        STARS = "**********"
        op = dedent(
            f"""\
            ! XDS.INP file for Rotation Electron Diffraction generated by `vetikkehva`
            ! {datetime.datetime.now()}
            ! For definitions of input parameters, see:
            ! http://xds.mpimf-heidelberg.mpg.de/html_doc/xds_parameters.html

            ! {STARS} Job control {STARS}
            !JOB= XYCORR INIT COLSPOT IDXREF
            !JOB= DEFPIX XPLAN INTEGRATE CORRECT
            !JOB= CORRECT
            JOB= XYCORR INIT COLSPOT IDXREF DEFPIX XPLAN INTEGRATE CORRECT

            MAXIMUM_NUMBER_OF_JOBS=4
            MAXIMUM_NUMBER_OF_PROCESSORS=4

            ! ********** Data images **********

            NAME_TEMPLATE_OF_DATA_FRAMES= data/0????.img   SMV
            DATA_RANGE=           1 439
            SPOT_RANGE=           1 439
            BACKGROUND_RANGE=     1 439
            EXCLUDE_DATA_RANGE=10 10
            EXCLUDE_DATA_RANGE=20 20
            EXCLUDE_DATA_RANGE=30 30
            EXCLUDE_DATA_RANGE=40 40
            EXCLUDE_DATA_RANGE=50 50
            EXCLUDE_DATA_RANGE=60 60
            EXCLUDE_DATA_RANGE=70 70
            EXCLUDE_DATA_RANGE=80 80
            EXCLUDE_DATA_RANGE=90 90
            EXCLUDE_DATA_RANGE=100 100
            EXCLUDE_DATA_RANGE=110 110
            EXCLUDE_DATA_RANGE=120 120
            EXCLUDE_DATA_RANGE=130 130
            EXCLUDE_DATA_RANGE=140 140
            EXCLUDE_DATA_RANGE=150 150
            EXCLUDE_DATA_RANGE=160 160
            EXCLUDE_DATA_RANGE=170 170
            EXCLUDE_DATA_RANGE=180 180
            EXCLUDE_DATA_RANGE=190 190
            EXCLUDE_DATA_RANGE=200 200
            EXCLUDE_DATA_RANGE=210 210
            EXCLUDE_DATA_RANGE=220 220
            EXCLUDE_DATA_RANGE=230 230
            EXCLUDE_DATA_RANGE=240 240
            EXCLUDE_DATA_RANGE=250 250
            EXCLUDE_DATA_RANGE=260 260
            EXCLUDE_DATA_RANGE=270 270
            EXCLUDE_DATA_RANGE=280 280
            EXCLUDE_DATA_RANGE=290 290
            EXCLUDE_DATA_RANGE=300 300
            EXCLUDE_DATA_RANGE=310 310
            EXCLUDE_DATA_RANGE=320 320
            EXCLUDE_DATA_RANGE=330 330
            EXCLUDE_DATA_RANGE=340 340
            EXCLUDE_DATA_RANGE=350 350
            EXCLUDE_DATA_RANGE=360 360
            EXCLUDE_DATA_RANGE=370 370
            EXCLUDE_DATA_RANGE=380 380
            EXCLUDE_DATA_RANGE=390 390
            EXCLUDE_DATA_RANGE=400 400
            EXCLUDE_DATA_RANGE=410 410
            EXCLUDE_DATA_RANGE=420 420
            EXCLUDE_DATA_RANGE=430 430

            ! ********** Crystal **********

            !SPACE_GROUP_NUMBER= 63
            !UNIT_CELL_CONSTANTS= 18.11 20.53 7.528 90 90 90

            !REIDX=                       !Optional reindexing transformation to apply on reflection indices
            FRIEDEL'S_LAW=TRUE            !TRUE is default

            !phi(i) = STARTING_ANGLE + OSCILLATION_RANGE * (i - STARTING_FRAME)
            STARTING_ANGLE= -43.9000
            STARTING_FRAME= 1

            !MAX_CELL_AXIS_ERROR=         !0.03 is default
            !MAX_CELL_ANGLE_ERROR=        !2.0  is default

            !TEST_RESOLUTION_RANGE=       !for calculation of Rmeas when analysing the intensity data for space group symmetry in the CORRECT step.
            !MIN_RFL_Rmeas=               !50 is default - used in the CORRECT step for identification of possible space groups.
            !MAX_FAC_Rmeas=               !2.0 is default - used in the CORRECT step for identification of possible space groups.

            ! ********** Detector hardware **********

            NX=516     NY=516             !Number of pixels
            QX=0.0550  QY=0.0550          !Physical size of pixels (mm)
            OVERLOAD= 130000              !default value dependent on the detector used
            TRUSTED_REGION= 0.0  1.4142   !default "0.0 1.05". Corners for square detector max "0.0 1.4142"
            SENSOR_THICKNESS=0.30
            AIR=0.0

            ! ********** Trusted detector region **********

            !Mark cross as untrusted region
            UNTRUSTED_RECTANGLE= 255 262 0 517
            UNTRUSTED_RECTANGLE= 0 517 255 262

            !VALUE_RANGE_FOR_TRUSTED_DETECTOR_PIXELS=  !6000 30000 is default, for excluding shaded parts of the detector.
            !MINIMUM_ZETA=                             !0.05 is default
            
            INCLUDE_RESOLUTION_RANGE= 20.00 0.80

            !Ice Ring exclusion, important for data collected using cryo holders
            !EXCLUDE_RESOLUTION_RANGE= 3.93 3.87       !ice-ring at 3.897 Angstrom
            !EXCLUDE_RESOLUTION_RANGE= 3.70 3.64       !ice-ring at 3.669 Angstrom
            !EXCLUDE_RESOLUTION_RANGE= 3.47 3.41       !ice-ring at 3.441 Angstrom (Main)
            !EXCLUDE_RESOLUTION_RANGE= 2.70 2.64       !ice-ring at 2.671 Angstrom
            !EXCLUDE_RESOLUTION_RANGE= 2.28 2.22       !ice-ring at 2.249 Angstrom (Main)
            !EXCLUDE_RESOLUTION_RANGE= 2.102 2.042     !ice-ring at 2.072 Angstrom - strong
            !EXCLUDE_RESOLUTION_RANGE= 1.978 1.918     !ice-ring at 1.948 Angstrom - weak
            !EXCLUDE_RESOLUTION_RANGE= 1.948 1.888     !ice-ring at 1.918 Angstrom - strong
            !EXCLUDE_RESOLUTION_RANGE= 1.913 1.853     !ice-ring at 1.883 Angstrom - weak
            !EXCLUDE_RESOLUTION_RANGE= 1.751 1.691     !ice-ring at 1.721 Angstrom - weak

            ! ********** Detector geometry & Rotation axis **********

            DIRECTION_OF_DETECTOR_X-AXIS= 1 0 0
            DIRECTION_OF_DETECTOR_Y-AXIS= 0 1 0

            ORGX= 256.36    ORGY= 249.04           !Detector origin (pixels). Often close to the image center, i.e. ORGX=NX/2; ORGY=NY/2
            DETECTOR_DISTANCE= +439.48            !Can be negative. Positive because the detector normal points away from the crystal.

            OSCILLATION_RANGE= 0.2336
            !OSCILLATION_RANGE 0.2303               !Calibrated value if above one is too far off

            ROTATION_AXIS= -0.6204 0.7843 0.0000

            ! ********** Incident beam **********

            X-RAY_WAVELENGTH= 0.0251              !used by IDXREF
            INCIDENT_BEAM_DIRECTION= 0 0 1        !The vector points from the source towards the crystal

            ! ********** Background and peak pixels **********

            !NBX=7     NBY=7                      !3 is default
            BACKGROUND_PIXEL= 2.0                  !2.0 is default
            !STRONG_PIXEL= 2.5                     !3.0 is default
            !MAXIMUM_NUMBER_OF_STRONG_PIXELS=     !1500000 is default
            !MINIMUM_NUMBER_OF_PIXELS_IN_A_SPOT=  !6 is default
            !SPOT_MAXIMUM-CENTROID=               !2.0 is default
            SIGNAL_PIXEL= 6                       !3.0 is default

            ! ********** Refinement **********

            REFINE(IDXREF)=    BEAM AXIS ORIENTATION CELL !POSITION 
            REFINE(INTEGRATE)= !POSITION BEAM AXIS !ORIENTATION CELL
            REFINE(CORRECT)=   BEAM AXIS ORIENTATION CELL !POSITION 

            ! ********** Indexing **********

            MINIMUM_FRACTION_OF_INDEXED_SPOTS= 0.25    !0.50 is default.
            """
        )

        with open(outfile, "w") as wf:
            wf.write(op)


@app.command()
def run_xds(input_path: Annotated[pathlib.Path, typer.Argument()] = pathlib.Path(".")):
    with tempfile.TemporaryDirectory() as workdir:
        workdir = pathlib.Path(workdir)
        with open(input_path / "cred.toml", "rb") as f:
            data = tomllib.load(f)
        xds_conf = XdsConfig.model_validate(data)

        xds_conf.to_xds_inp(workdir / "XDS.INP")
        os.symlink(input_path / "data", workdir / "data", target_is_directory=True)

        print([f for f in (workdir / "data").iterdir()])

        subprocess.run("xds", cwd=workdir)

        print(workdir)
        input()


if __name__ == "__main__":
    app()