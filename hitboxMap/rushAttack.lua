return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.0",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 12,
  height = 6,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 7,
  nextobjectid = 9,
  properties = {},
  tilesets = {
    {
      name = "1",
      firstgid = 1,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 12,
      image = "../assets/Franky/rushAttack/1.png",
      imagewidth = 192,
      imageheight = 96,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 72,
      tiles = {}
    },
    {
      name = "2",
      firstgid = 73,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 12,
      image = "../assets/Franky/rushAttack/2.png",
      imagewidth = 192,
      imageheight = 96,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 72,
      tiles = {}
    },
    {
      name = "3",
      firstgid = 145,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 12,
      image = "../assets/Franky/rushAttack/3.png",
      imagewidth = 192,
      imageheight = 96,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 72,
      tiles = {}
    },
    {
      name = "4",
      firstgid = 217,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 12,
      image = "../assets/Franky/rushAttack/4.png",
      imagewidth = 192,
      imageheight = 96,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 72,
      tiles = {}
    },
    {
      name = "tiles",
      firstgid = 289,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 14,
      image = "../assets/tiles.png",
      imagewidth = 224,
      imageheight = 64,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 56,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 12,
      height = 6,
      id = 6,
      name = "ground",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 12,
      height = 6,
      id = 1,
      name = "frame1",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0,
        13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 0,
        25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 0,
        37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 0,
        49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 0,
        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 12,
      height = 6,
      id = 2,
      name = "frame2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
        85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
        97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
        109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
        121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132,
        133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 12,
      height = 6,
      id = 3,
      name = "frame3",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156,
        157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168,
        169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180,
        181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192,
        193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204,
        205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 12,
      height = 6,
      id = 4,
      name = "frame4",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228,
        229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240,
        241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252,
        253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264,
        265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276,
        277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "hitboxes",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "Hitbox1",
          type = "rushAttack1",
          shape = "ellipse",
          x = 63.25,
          y = 25.125,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "Hitbox1",
          type = "rushAttack1",
          shape = "ellipse",
          x = 37.8125,
          y = 24.625,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "Hitbox2",
          type = "rushAttack2",
          shape = "ellipse",
          x = 63.25,
          y = 25.13,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "Hitbox2",
          type = "rushAttack2",
          shape = "ellipse",
          x = 38.13,
          y = 25.13,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "Hitbox3",
          type = "rushAttack3",
          shape = "ellipse",
          x = 63.25,
          y = 25.13,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "Hitbox3",
          type = "rushAttack3",
          shape = "ellipse",
          x = 37.5625,
          y = 25.13,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "Hitbox4",
          type = "rushAttack4",
          shape = "ellipse",
          x = 63.25,
          y = 25.13,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "Hitbox4",
          type = "rushAttack4",
          shape = "ellipse",
          x = 37.5625,
          y = 25.13,
          width = 48.875,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
