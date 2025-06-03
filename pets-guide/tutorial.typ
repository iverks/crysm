#import "@preview/abbr:0.2.3": a as acr
#import "@preview/unify:0.7.1": num, unit, qty, numrange
#import "@preview/codly:1.3.0": *
#import "_frames.typ": note


#let PETS = acr("PETS")

= Preprocessing

== Correcting for the central cross <section:central-cross-correction>


The electron detector of our #acr("TEM") consists of four subdetectors as shown in #ref(<fig:detector-gap>) a).
These subdetectors are separated from each other by a small gap.
This gap is on the scale of a few pixels.
We need to correct for this both in our calibration images and in the data used for reconstruction.

#include "figures/fig-detector-gap.typ"
// #include "figures/fig-detector-gap-geometry.typ"

In addition, electrons that hit this gap are detected by the nearby detectors with a certain probability, effectively increasing their intensity by a fixed factor.
This is what gives rise to the characteristic bright cross.
We call this fixed factor the "correction factor".
The central four pixels collect electrons from an even larger area, and thus have their intensity increased by another factor.
This factor we name the "central four factor".
To correct for these effects we first need to characterize our detector on a flatfield image such as the one shown in #ref(<fig:flatfield-image>).
A flatfield image is captured by illuminating the entire detector evenly and capturing an image of vacuum, meaning there is nothing inside the field of view.

#figure(
  image("/images/flatfield_200kV_24bit.png", width: 60%),
  caption: [
    Example flatfield image. Here we can see the dead pixels some black and some white.
    The central cross is brighter than the average pixel.
    The central four pixels are even brighter.
  ],
) <fig:flatfield-image>

The crysm package contains a script to calculate the correction factors from a flatfield image.
To run it, we use the command `crysm find-center-cross-correction PATH/TO/FLATFIELD_IMAGE.mib`.
The flatfield image can be a .mib or a .tiff image.
This calculates the correction factor and the central four factor, and depending on them suggests either two or four additional pixels be added in the center, but ultimately this should be chosen by the analyst. The currently used correction factors are show in #ref(<tab:correction-factors>).

#figure(
  caption: [Currently used central cross correction values as of 15.05.2025.],
  table(
    columns: 2,
    [Variable], [Value],
    [Additional pixels], [2],
    [Correction factor], [2.196],
    [Central four factor], [4.051],
  ),
) <tab:correction-factors>

After finding the correction factors, the images must be converted. To do this, navigate to the experiment folder and run the command
`crysm pets-correct-central-cross --additional-pixels 2 --correction-factor 2.196 --central-four-factor 4.051`
using the previously determined values. This generates a new folder `tiff_corr` containing the corrected images that will be used in #ref(<section:use-corrected-images>).

== Calibration of pixel size <section:calibration>

Finding the correct pixel size, in #PETS referred to as "aperpixel", is essential. The parameter tells us how many inverse Ångström in reciprocal space each pixel in the image represents. It requires some knowledge of crystallography and the dedicated sample, so it is recommended to get help with this the first time, and its details are thus not covered in this manual.

The calibration of pixel size depends on the chosen number of additional pixels when correcting for the central cross. In order to create a widened calibration image we can use the command
`crysm pets-correct-central-cross-calibration --additional-pixels 2 PATH/TO/INPUT_IMAGE.tiff PATH/TO/OUTPUT_IMAGE.tiff`. The input image can be either .tiff or .mib, but the output must be .tiff.

#note[Correction tool][Advanced use][
  Optionally it is also possible to set `--correction-factor 2.196 --central-four-factor 4.051`, but it is not necessary since we do not care about the intensity correction for the pixel size calibration image.

  By using `crysm pets-correct-central-cross-calibration --additional-pixels 0 --correction-factor 1 --central-four-factor 1 input.mib output.tiff`, this script can be used as a .mib to .tiff conversion tool.
]

The used calibration values as of writing this are presented in #ref(<tab:calibration-values>).

#figure(
  caption: [Pixel size calibration values for the acceleration voltage of #qty("200", "kV") used as of 01.05.2025.],
  table(
    columns: 4,
    [Gap correction], [120cm], [150cm], [200cm],
    [Not corrected], [0.010207], [0.007929], [0.006167],
    [Corrected 2px], [-], [0.007859], [0.006062],
    [Corrected 4px], [-], [0.007682], [-],
  ),
) <tab:calibration-values>

== Setting Aperpixel and other constants in the .pts file <section:setting-pts-params>

It is recommended to set as many parameters in the config file as possible even though they often are settable in the graphical user interface. This is to save time when restarting the analysis if anything happens to the project. The frame scale should be set to the value calculated above. Remember that the calibration constant is different when correcting for the central cross widening than when not doing it.

=== lambda

The lambda value is the wavelength of the electrons.
Instamatic sets this to a configurable constant.
For our setup this is #qty(0.025, "per Angstrom"), which is correct for #qty(200, "kV").
Be aware that this value is *not* automatically updated when the acceleration voltage is changed.
The value should be calculated based on the used acceleration voltage.
The corresponding wavelengths for our selection of acceleration voltages are listed in #ref(<tab:wavelengths>).

#figure(
  caption: [Wavelengths for our selection of acceleration voltages.],
  table(
    columns: (auto, auto),
    [Acceleration voltage [#unit("kV")]], [Wavelength [#unit("per Angstrom")]],
    [80], [0.041757],
    [200], [0.025079],
  ),
) <tab:wavelengths>

=== Aperpixel

The Aperpixel value is explained in the section above.

=== phi

Phi is the semiangle of a tilt step, meaning it should be half of the tilt step between two images.
In the future Instamatic will set this value automatically.
When using `crysm` to calibrate angles (next step) it will be overridden. A reasonable value is #qty("0.035", "degree").

=== omega

Omega is the rotation axis. It is *not* automatically set by Instamatic. To find it we need to inspect the images and observe which axis the Ewald sphere moves across. Only an approximate value is needed as #PETS does a good job of refining it. The value should be the same across experiments. If it is not known yet, it can be found at a later step. A reasonable value is #qty("232", "degree").

=== bin

Bin is how many pixels should be binned together. According to the official #PETS documentation, this makes the analysis faster and more robust for images that are larger than 1000x1000 pixels. Since our images are not, we leave it at $1$.

=== reflectionsize

The reflection size is the diameter used of the reflections.
It should be large enough to encompass strong spots, but not so large that it overlaps with neighboring points.
An example of correctly sized reflections can be seen in #ref(<fig:laue-circle-movement>), where the sizes of the small green circles are set by the reflectionsize.
It is fine to leave the reflectionsize as 20 and correct it interactively before running the peak search.

=== noiseparameters

Noiseparameters are two numbers. In the #acr("GUI") they are referred to as $G gamma$ and $psi$.

The first number is the expectation value for how many pixels light up per electron hitting the detector. This value should usually be between #numrange("1.3", "1.5"). Finding the value is not simple, but can be done by inspecting flatfield images with very low dose such that single electron impacts are discernible. It should also be discussed with the producer of the detector. The value used for our detector is $1.5$, according to analysis done by Lukas Palatinus.

The second number is the constant noise when no electrons are hitting the detector. For our detector this is simply $0.0$.

After setting the parameters, the file should look something like this:

#block(breakable: false)[
  ```properties
  lambda 0.025079
  Aperpixel 0.00285546
  phi 0.035
  omega 231.0
  bin 1
  reflectionsize 5
  noiseparameters 1.5 0

  imagelist
  tiff/00001.tiff   -61.4524 0.00
  tiff/00002.tiff   -61.3748 0.00
  tiff/00003.tiff   -61.2973 0.00
  ...
  tiff/01610.tiff    63.3724 0.00
  tiff/01611.tiff    63.4500 0.00
  endimagelist
  ```
]

It is advised to create a backup of this `pets.pts` file in case anything happens to it by copying it to `pets.bak.pts`.

== Calibration of rotation angles

The #PETS input files (.pts) contain a list of all frames, their image and their corresponding angle in the `imagelist` section.

Instamatic assumes the angles of each image are equally spaced when generating the #PETS input file. This is not exactly true.
The images have timestamps in their header, which we can use to recalibrate the rotation angles. In the dataset folder run `crysm pets-calibrate-angles`.
This generates a new input file `pets-fromtime.pts` where the orientation angle of each frame is calibrated, and the `phi` parameter is set to the median tilt step of the new dataset.

== Use the central cross corrected images <section:use-corrected-images>

The #PETS config file must be modified to use the central cross corrected images generated in #ref(<section:central-cross-correction>). Using the multiline editing capabilities of your text editor, add change the image path of all images from `tiff/*.tiff` to `tiff_corr/*tiff`. In VSCode or Notepad++ this can be done by placing the cursor on the first line of the image list, scrolling to the bottom of the file and clicking the last line of the image list while holding *SHIFT* and *ALT*.

#block(breakable: false)[
  ```properties
  lambda 0.025079
  Aperpixel 0.00285546
  phi 0.035
  omega 231.0
  bin 1
  reflectionsize 5
  noiseparameters 1.5 0

  imagelist
  tiff_corr/00001.tiff   -60.4956 0.00
  tiff_corr/00002.tiff   -59.8215 0.00
  tiff_corr/00003.tiff   -59.7463 0.00
  ...
  tiff_corr/01610.tiff   63.3753 0.00
  tiff_corr/01611.tiff   63.4500 0.00
  endimagelist
  ```
]

== Generate a beamstop-file <section:generate-beamstop>

When using central cross correction #ref(<section:central-cross-correction>), a beam stop should not be necessary.
If a beam stop mask is to be used anyways for the central cross, it can be created with `crysm` using the command `crysm pets-create-beamstop`.
The command takes two parameters, image width and beamstop width. The image width is the width of the image after being corrected for the central cross. If using no additional pixels this is usually 512, and with an additional pixels value of 2 it becomes 514. The beamstop width is up to the user.
The command is then `crysm pets-create-beamstop --image-width 514 --beamstop-width 6 beamstop.xyz`.
If it is only desirable to mask the central four pixels, a beamstop can be created with the command
`crysm pets-create-beamstop --image-width 514 --beamstop-width 4 --beamstop-kind square beamstop.xyz`.
The beam stop files can be reused in other projects with the same image and beamstop widths.

#note[Summary][Crysm preprocessing commands][
  Find correction constants\
  `crysm find-center-cross-correction PATH/TO/flatfield_200kV_24bit.mib`

  Central cross correct all images in dataset\
  `crysm pets-correct-central-cross-calibration --additional-pixels 0 --correction-factor 1 --central-four-factor 1 input.mib output.tiff`

  Central cross correct pixel calibration image\
  `crysm pets-correct-central-cross-calibration --additional-pixels 2 PATH/TO/INPUT_IMAGE.tiff PATH/TO/OUTPUT_IMAGE.tiff`

  Correct angles in config file\
  `crysm pets-calibrate-angles`

  Generate beamstop file\
  `crysm pets-create-beamstop --image-width 516 --beamstop-width 6 --beamstop-kind cross beamstop.xyz`
]



#pagebreak(weak: true)
= Data reduction in PETS

Details of the steps in #PETS are presented in the #PETS manual, which is recommended supplementary reading #cite(<pets_manual>).
This manual is meant as a more instructive manual for specifically our workflow.
An overview of the workflow is presented in #ref(<fig:pets-flowchart>).

#include "figures/flowchart.typ"

== Parameters <section:pets-params>

Set geometry to continuous rotation.
Estimate and set reflection diameter, should be a bit smaller than a medium sized peak.
Verify calibration constant is set to the calibrated value.
The defaults for the parameters: max d\* for integration, max d\* for peak search and min d\* of $1.4$, $1.4$ and $0.05$ are fine.
The detector noise parameters should be set from #ref(<section:setting-pts-params>).
For 12 bit datasets the detector saturation limit should be set to #num("4095"). For 24 bit the saturation limit should be set as high as possible, which is #num("2 000 000 000").

If a beamstop was generated in #ref(<section:generate-beamstop>), it should be loaded at this point by clicking "Yes" and "Load" and selecting the given file.

Click on "Detect" to detect bad pixels. It usually detects $82$, missing around $25$. If some pixels go undetected, they can be added using `crysm`. First export the pixels from the #acr("GUI") to a file `dead_pixels.txt`.
Then run the command
`crysm mark-dead-pixels --dead-pixels dead_pixels.txt tiff_corr/00001.tiff`.
This loads the dead pixels from the file and the image `tiff_corr/00001.tiff`. To toggle a dead pixel, double click the pixel in the image.
To verify that the pixel really is dead, you can scroll through the images using the buttons "d" (aDvance) and "a" (bAck).
Closing the window saves the modifications to the opened file automatically.
The saved dead pixel files can be reused in other projects with the same image width.

#figure(
  image("images/crysm_marking_dead_pixels.png", width: 60%),
  caption: [#acr("GUI") for marking dead pixels in `crysm`.],
)

== Peak search <section:peak-search>

When doing the peak search, we have had better success using the direct beam for center determination than with the friedel pairs. According to the creator of #PETS, using the direct bean introduces a bias, while using friedel pairs introduces noise.
Sometimes increasing the I/sigma ratio to $15$ or $20$ is a good way to filter out noise if there are too many peaks detected. If too few peaks are detected it can be reduced to $5$ or $3$. Usually, leaving it at the default value of $10$ is fine for #acr("cRED") data.
On the second run, the center determination should be set to "Use saved centers" to use the centers found in "Optimize frame geometry".

#note[Possible issue][The direct beam is in the central cross][
  If the direct beam is in the central cross, proceed by using the friedel pairs method. Then after finding the unit cell, run "Optimize frame geometry" with only "Frame orientation angles" and "Center of the diffraction patterns" enabled. Finally, rerun the peak search step using "Use saved centers".
]
== Tilt axis <section:tilt-axis>

The initial $omega$ angle should already be set to an initial estimate from #ref(<section:setting-pts-params>). Run the step without enabling "Global search for tilt axis position $omega$". Usually enabling the optimization of the $delta$ angle leads to worse results. Note that the $delta$ angle is refined on a frame by frame basis in #ref(<section:frame-geometry>).

#note[Help][Finding an initial guess for the tilt axis][
  // TODO: figur

  In #ref(<fig:laue-circle-movement>) we can see three equally spaced frames from the Mordenite 1 dataset.
  We can see the Laue circle, the intersection between a layer of the reciprocal crystal and the Ewald sphere, moving across the image.
  This should be present in most data sets, but not all, and the distance of the path from the origin might vary depending on the crystal orientation.



  The green lines for the tilt axis can be enabled by checking "Resolution rings, tilt axis and ice rings" in the "Image options" tab of the right window.
  The found peaks are marked with green rings when "Peak search" right below is checked and a peak search has been run.

  When looking through the images, you will see some frames where a circle can be traced.
  The rotation axis should be orthogonal to the direction of movement of the center of the circle.

  The rotation axis (green double lines in all images). Should be

  #figure(
    image("/images/rotation_axis/laue_circle_moving.png"),
    caption: [Three equidistant frames from the Mordenite 1 dataset.
      The found peaks are marked by small green rings and the rotation axis by a double line.
      Edited onto the image is an estimation of the Laue circle (red ring) and its center (red dot).
      In the last frame (c) the Laue circle centers of the other frames are marked by transparent red dots.
      The path of the center of the Laue circle is marked with a red dashed line.],
  ) <fig:laue-circle-movement>

]

#note[Possible issue][The tilt axis is unknown][
  If the tilt axis is unknown and can't be guessed from observing the path of the Ewald sphere over the images, "Global search for tilt axis position $omega$" can be enabled.
  Sometimes this finds a local minimum instead. Then it might be better to do many local searches from several initial guesses, for example every #qty(10, "degree") or #qty(20, "degree").
]

== Peak analysis <section:peak-analysis>

Clicking "Peak analysis" a plot of in-plane distances is shown. The plot has two curves, a red and a green curve. The red curve is the distances between each pair of peaks sorted in ascending order. The green curve is the derivative of the red curve.

We expect the red curve to have several distinct steps, and thus the green to have defined peaks.

#figure(
  grid(columns: 2)[
    #image("/images/mor2/Peak_analysis__In-plane_distances.png")
    a)
  ][
    #image("/images/mor2/Peak_analysis__3D_distances.png")
    b)
  ],
  caption: [a) In plane distances. b) 3D distances.],
)

Next, after clicking "Peak analysis (continue)" the same plot is presented, but for distances in the constructed 3D reciprocal space.
We again expect the red curve to have several distinct steps, and thus the green to have defined peaks.

Finally, click "Peak analysis (continue)" to finish the step. This step creates the reciprocal space constructions "xyz", "clust" and "dist" used in indexing.

// #note[Info][What does each step do?][
//   1. The first step analyzes the distance distribution between the peaks in each image as found by the peak finding procedure.
//   2. The second step analyses an auto convolution of the diffraction pattern, called the difference space.
// ]

== Find unit cell and orientation matrix <section:unit-cell>

Open the reconstruction by clicking "Find unit cell and orientation matrix".
Click find possible cells automatically.
If no cell is found, try to change the data used for indexing to "diff", the difference space.
If the issue persists, change back to "xyz" and select "from triplets" in the "Find possible cells automatically" section.
Finally if the issue still persists use "diff" and "from triplets".
If the found cell is incorrect we can try to modify the cell. Do however note that this is a sign that the data quality is low.

#note[Possible issue][The unit cell vectors are too long][
  If the detected cell has correct orientation, but one of the vectors is twice as long as it should be, open "Modify cell" and click "Go to supercell". The unit cell should then be corrected to the smallest one as shown in #ref(<fig:go-to-supercell>).

  #figure(
    image("/images/go_to_supercell.png", width: 100%),
    caption: [The unit vector might be too long.],
  ) <fig:go-to-supercell>
]



#note[Possible issue][Cannot find unit cell][
  If the unit cell cannot be found by automatic means it is possible to define it manually.
  It is advised to use the "diff" space or "clust" space for this task, due to their higher data density near the origin.

  Navigate to a high-symmetry direction, and rotate so that the grid is aligned to the x and y-axes. The histograms on the bottom and left should be as sharp as possible.
  Click the "Define directions" button to start. First, place the cursor on a point on the same row as the origin point.
  Make sure that the "order" is properly detected and set to the number of intervals your line spans, as shown in #ref(<fig:find-cell-manually>).
  Then check the "b" radio button, and place the cursor on a point on the same column as the origin point.
  Finally click the "a" button under "View along direction", and draw the last line such that all angles are #qty(90, "degree").
  The cell does not need to be perfect as it will be refined.

  #figure(
    image("images/mor2/Find_cell_manually.png", width: 80%),
    caption: [When finding the cell manually, we draw a direction vector and make sure the order value is equal to the count of intervals spanned by the vector.],
  ) <fig:find-cell-manually>
]

Finally, open the "Modify cell" tab and click "Reduce cell". This finds the Bravais class and orders the lattice parameters in a consistent order.

=== Refining cell

In this step there is no determined best way to do it. Instead two options are suggested.

#note[Option 1][Refinement with distortions][
  Refine the cell and distortions once per distortion in the order they are listed. Then refine the cell using "Refine cell from d". finally "Refine UB + cell" with the crystal system set either to "Triclinic" or the one suggested by #PETS.
]
#note[Option 2][Simple refinement][
  In the first run use "Refine cell from d". In the second run use "Refine UB + cell" with the crystal system set either to "Triclinic" or the one suggested by #PETS.
]


== Removing bad frames

If at this point some frames or ranges of frames have been deemed to be bad, for example because the particle moved out of the selected area aperture at the end of the rotation, the offending frames should be excluded from computation. This can be done with the "Frame dialog" window. In order to remove a range of frames from calculation, hold *SHIFT* while clicking the top and bottom images in the range. Then uncheck the box labeled "Use for calculation" as shown in #ref(<fig:remove-range-from-calculation>).

#figure(
  caption: [Remove a range of multiple images ],
  image("images/mor2/Uncheck_from_calculation.png", width: 60%),
) <fig:remove-range-from-calculation>

== Reciprocal space sections <section:reciprocal-space>

In the reciprocal space sections, we can specify the space group by comparing the reflection conditions/extinction rules to the tables.
This section might not be necessary as SHELX finds the space group automatically, but can be done to increase our certainty or confirm a suspicion without solving the structure.

Clicking the "Reciprocal-space sections" button creates a set of images of the reciprocal space planes.
Applying symmetry in the reconstruction helps completeness of the images, but might be a false safety net.
In the reciprocal space sections, the planes of where one of $h, k, l$ is set to one of $0, 1, 2$.
Comparing with the tables in IUCr vol A tables #cite(<international_tables_crystallography>).
The tables are available digitally at https://onlinelibrary.wiley.com/iucr/itc/Ac/ch1o6v0001/sec1o6o5.pdf.

#figure(
  image("/images/extinction_rules_reciprocal_sections.png", width: 60%),
  caption: [The $h k 0$ plane for Mordenite (Cmcm) has the reflection condition $h+k$,
    which can be seen by the missing reflections at $h = 3, k = 0$, $h = 4, k = 1$, $h = 5, k = 2$ etc.
    The grid is enabled with the "gr" button.
  ],
) <fig:reciprocal-space-sections-image>

#note[Possible issue][The reciprocal images are hard to read][
  Sometimes, the peaks in the generated reciprocal space images are very big, like the $h = 8, k = 0$ peak or the direct beam in #ref(<fig:reciprocal-space-sections-image>).
  If too many of the peaks are like this, the image is impossible to interpret.
  To avoid this issue, this step can be done manually in the 3D reconstruction instead.

  First, open the reconstruction by clicking "Find unit cell and orientation matrix".
  Use the buttons on the right labeled "a\*", "b\*" and "c\*" to align the reconstruction with the lattice.
  Use the "rectangle area selection" tool to select a plane, and the mentioned buttons to orient the view directly above the plane.
  Enable the lattice by checking "Show lattice", and grow it in the in-plane directions using the number inputs to the right of "Fold to cell".
  The lattice might obscure the points, but this can be avoided by toggling it off again.

  #figure(
    image("/images/extinction_rules.png"),
    caption: [The $h k 0$ plane for Mordenite (Cmcm) has the reflection condition $h+k$.
      Here, the reflections have been highlighted using "Show reflections",
      and the space is folded to 4 by 4 unit cells to get a higher density of points for illustrative purposes.
    ],
  )
]

== Process frames for integration <section:process-frames>

When processing frames, always use the "Fit profile" intensity determination method.
The values "Rocking curve width" and "Apparent mosaicity" are shared between "Process frames", "Optimize reflection profile" and "Optimize frame geometry".
For the first run they should already be set to reasonable values.
The rocking curve width default of $0.001$ is good, and the apparent mosaicity default of $0.1$ is good.

== Optimize reflection profile <section:optimize-profile>

The "Precession angle/tilt semiangle" should be set from #ref(<section:setting-pts-params>). The "Minimum I/$sigma$(I)" is fine set to its default 10, but can be increased to 15 or 20 as in #ref(<section:peak-search>) to filter out noise. It is only used for the display of the rocking curve, not for any calculations. In this step the "Rocking curve width" and "Apparent mosaicity" values are refined.

== Optimize frame geometry <section:frame-geometry>

Optimize frame geometry optimizes for common frame-by-frame errors in #acr("3D ED") data.

The first time running this, "Uniform intensities" should be chosen as simulation method. If a successful integration has been performed, e.g. it's the second round of optimization, the "Integrated intensities" method is generally more accurate.

When selecting the geometrical parameters to optimize for, the default is to optimize for "Frame orientation angles", "Center of the diffraction pattern" and "Apparent mosaicity", but not "RC width" or any of the "Distortions".
// I tend to enable "Distortions", and of them "Magnification" and "Elliptical", but any combinations should be fine.
Beware to _not_ enable both "RC width" and "Apparent mosaicity", as they are correlated.

For the rotation angles, the assumption is that they are related to the previous and next frames, thus by default there is a smoothing applied. By default this is set to a polynomial of 4th order. For very misaligned data, a moving average might be better. For continuous rotation data with a small tilt step ($<0.5 degree$) the order of the moving average smoothing can be increased to 10-20.

== Finalize integration <section:finalize-integration>

To speed up the process slightly you can disable dynamic refinement as it is not used in the rest of the process as of writing.
After running, make sure the detected Laue class for scaling is correct.

== Automatic workflow

Once the process is mastered, it can be sped up using the automatic workflow. I prefer finding and refining the unit cell manually and then running the rest of the steps automatically.

= Structure solution in Olex2 + SHELX

Copy the file `<jobname>_shelx.hkl` into a new folder "shelx". Run the terminal command:

```bash
# Format
python3 -m edtools.make_shelx -s <SPACE_GROUP> -m <COMPOSITION> -c <A> <B> <C> <ALPHA> <BETA> <GAMMA>
# Example
python3 -m edtools.make_shelx -s Pnma -m Si1 O2 -c 13.029 19.994 20.102 90 90 90
```

Note that you must explicitly specify the 1 that is normally omitted from $"SiO"_2$.

Rename the generated `shelx.ins` such that it has the same name as your `.hkl` file. It might be nice to save a backup of the `.ins` file if you want to try multiple `.hkl` files with the same unit cell, because Olex2 modifies the `.ins` file when run.

Start the Olex2 program and open the `.ins` file. Open the "Work" tab and click the arrow to the right of the "solve" button.
This opens the options for structure solution.
Since we expect slightly higher errors than in X-ray data, we need to increase the $alpha$ threshold for selecting possible space groups.
This is done in the "COMMAND LINE" section under the "Solution settings extra" dropdown as shown in #ref(<fig:set-shelxt-flag>).
There we can set the `-a` flag to a higher value, for example `-a"0.6"`.
If your structure is centrosymmetric, make sure the output from SHELXT does *not* say "0 Centrosymmetric and N non-centrosymmetric space groups evaluated".
If this is the case, increase the value passed to the `-a` flag.

#figure(
  image("/images/set_flags_in_shelx.png", width: 80%),
  caption: [Flags can be set for SHELXT in Olex2 using the "Solution settings extra" dropdown.],
) <fig:set-shelxt-flag>

Then, solution can be started by clicking the "solve" button.
Use the command `pack cell` in the command line in the bottom left corner to grow the structure to a full cell for easier inspection.
Use the command `fuse` to revert back to the anisotropic unit before refinement.

For refinement we refer to the previous manual, whose first version is openly available at #cite(<teien>, supplement: [Appendix A.3]). An updated version can be found in the private repository https://github.com/TEM-Gemini-Centre/developments.

#note[Possible issue][The solution looks correct, but stretched][
  If the solved structure has the components of the expected structure,
  for example the rings we expect from the ZSM-5 structure in this example,
  this may be caused by the order of the unit cell parameters being wrong.
  This can be solved by reordering the lattice parameters in the .ins-file and running the structure solution again.

  #figure(
    image("images/experiment_6/stretched_solution.png"),
    caption: [Sometimes the structure looks stretched compared to the compared result, here in the y-direction.],
  )
]

#note[Potential issue][SHELXT finds the wrong space group][
  If SHELXT is unable to find the correct space group, the space group can be manually enforced using the command line flag `-S[SPACE GROUP]`, e.g. `-SPnma`.
  Using Olex2, this is done in the "COMMAND LINE" section under the "Solution settings extra" dropdown as shown in #ref(<fig:set-shelxt-flag>).
]

== Without edtools

Edtools is not hard to install, but it's dependencies `cctbx.python` or `sginfo` are.
When making .ins files, edtools does two things differently from #PETS.
It sets the symmetries from the space group supplied, and the composition with structure factors.
To compensate for the first, SHELXT can find the symmetries from the Laue group that can be supplied using the command line parameter `-l[LAUE GROUP NUMBER]`.
When running in Olex2, the `-l` flag can be set in the #acr("GUI") as shown in #ref(<fig:set-shelxt-flag>).
This has the added bonus that we don't need to determine the space group, only the Laue group, which is automatically determined by #PETS during integration.

To compensate for the second is not necessary, we only need to add the composition, for example adding $"SiO"_2$:

```
SFAC O Si
UNIT 2 1
```

SHELX knows the scattering factors for the given atoms, so the result is equal to when inserting the composition along with the scattering factors.

The laue group numbers are between 1 and 17, and the human-readable Laue group is printed by SHELXT when running. The echoed Laue groups for each number are tabulated in #ref(<tab:laue-group-numbers>).

#figure(
  caption: [The laue groups corresponding to the laue group numbers in SHELXT.],
  columns(
    2,
    gutter: -1%,
    [
      #table(
        columns: 2,
        [Number], [Laue group],
        [1], $overline(1)$,
        [2], [2/m],
        [3], [mmm],
        [4], [4/m],
        [5], [4/mmm],
        [6], [$overline(3)$ (rhombohedral primitive)],
        [7], [$overline(3)$ (hexagonal axes)],
        [8], [$overline(3)$m (rhombohedral primitive)],
        [9], [$overline(3)$1m (hexagonal axes)],
      )
      #colbreak()
      #table(
        columns: 2,
        [Number], [Laue group],
        [10], [$overline(3)$m1 (hexagonal axes)],
        [11], [6/m],
        [12], [6/mmm],
        [13], [m$overline(3)$],
        [14], [m$overline(3)$m],
        [15], [all hexagonal and trigonal],
        [16], [monoclinic with $a$ unique],
        [17], [monoclinic with $c$ unique],
      )
    ],
  ),
) <tab:laue-group-numbers>

The process described above is automated into the command `crysm pets-solve -m <COMPOSITION> PROJECT.pts2`.
This command copies the `PROJECT_shelx.ins` and `PROJECT_shelx.hkl` files into the `shelx` folder, overwriting any colliding files,
writes the composition into the `.ins` file, and runs `shelxt` using `-a0.6` and `-l[LAUE GROUP]`.
It reads the Laue group from the settings that are stored in your `.pts2`-file, so make sure that it is saved,
and that the "Laue group for scaling" value in the "Finalize integration" step is correct.
This should be verified by looking at the output from SHELXT.


// = Strucure solution in JANA

// _This is just the outline, because we had better luck with Olex than with JANA._

// - Create new folder for JANA
// - Copy `.cif_pets` file from PETS folder to JANA folder

// == Superflip window

// - Insert composition (Si O2 for Mordenite)
// - EDMA - Fixed composition if you know composition exactly
