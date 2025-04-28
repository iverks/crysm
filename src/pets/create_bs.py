def create_bs(gap_width=4, img_width=512):
    # 0 - a - b - img_width
    a = img_width // 2 - gap_width // 2
    b = img_width // 2 + gap_width // 2
    c = img_width
    beamstop = f"""
    0 {a}
    0 {b}
    {a} {b}
    {a} {c}
    {b} {c}
    {b} {b}
    {c} {b}
    {c} {a}
    {b} {a}
    {b} 0
    {a} 0
    {a} {a}
    """
    return beamstop
