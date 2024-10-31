from datetime import datetime

import pyparsing as pp
from pydantic import BaseModel
from pyparsing import pyparsing_common as pc


class CredLog(BaseModel):
    collection_time: datetime
    start_angle: float  # degrees
    end_angle: float  # degrees
    exposure_time: float  # s
    aquisition_time: float  # s
    total_time: float  # s
    spot_size: int
    camera_length: int  # mm
    oscillation_angle: float
    number_of_frames: int
    image_interval: int  # every n frames
    diff_focus_defocused: int | None
    defocused_exposure_time: float | None

    number_of_images: int


def parse_cred():
    kw_coll_time = pp.Literal("Data Collection Time")
    kw_start_angle = pp.Literal("Starting angle")
    kw_end_angle = pp.Literal("Ending angle")
    kw_exposure_time = pp.Literal("Exposure time")
    kw_aquisition_time = pp.Literal("Aquisition time")
    kw_total_time = pp.Literal("Total time")
    kw_spot_size = pp.Literal("Spot size")
    kw_cam_len = pp.Literal("Camera length")
    kw_osc_angle = pp.Literal("Oscillation angle")
    kw_no_of_frames = pp.Literal("Number of frames")
    kw_image_interval = pp.Literal("Image interval")
    kw_no_of_images = pp.Literal("Number of images")
    colon_sep = pp.ZeroOrMore(" ") + ":" + pp.ZeroOrMore(" ")
    degrees = pp.ZeroOrMore(" ") + "degrees"
    seconds = pp.ZeroOrMore(" ") + "s"
    millimeters = pp.ZeroOrMore(" ") + "mm"

    ln_coll_time = kw_coll_time + colon_sep + pc.iso8601_datetime
    ln_start_angle = kw_start_angle + colon_sep + pc.number("start_angle") + degrees
    ln_end_angle = kw_end_angle + colon_sep + pc.number("end_angle") + degrees
    ln_xp_time = kw_exposure_time + colon_sep + pc.number("exposure_time") + seconds
    ln_aq_time = kw_aquisition_time + colon_sep + pc.number("aquisition_time") + seconds
    ln_total_time = kw_total_time + colon_sep + pc.number("total_time") + seconds
    ln_spot_size = kw_spot_size + colon_sep + pc.integer("spot_size")
    ln_cam_len = kw_cam_len + colon_sep + pc.integer("camera_length") + millimeters
    ln_osc_angle = kw_osc_angle + colon_sep + pc.integer("oscillation_angle") + degrees
    ln_no_of_frames = kw_no_of_frames + colon_sep + pc.integer("number_of_frames")
    ln_image_interval = kw_image_interval + colon_sep + pc.integer("image_interval")
    ln_no_of_images = kw_no_of_images + colon_sep + pc.integer("number_of_images")

    line = (
        ln_coll_time
        | ln_start_angle
        | ln_end_angle
        | ln_xp_time
        | ln_aq_time
        | ln_total_time
        | ln_spot_size
        | ln_cam_len
        | ln_osc_angle
        | ln_no_of_frames
        | ln_image_interval
        | ln_no_of_images
    )

    parser = pp.OneOrMore(line)

    res = parser.parse_string("something")
    fin = CredLog.model_validate(res)


if __name__ == "__main__":
    parse_cred()
