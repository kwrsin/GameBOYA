return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 8,
  height = 8,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 9,
  nextobjectid = 63,
  properties = {},
  tilesets = {
    {
      name = "actorpositions",
      firstgid = 1,
      class = "",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      columns = 3,
      image = "../../../assets/images/actorpositions.png",
      imagewidth = 192,
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
        width = 64,
        height = 64
      },
      properties = {},
      wangsets = {},
      tilecount = 3,
      tiles = {}
    }
  },
  layers = {
    {
      type = "imagelayer",
      image = "../../../assets/images/level01bg.png",
      id = 2,
      name = "画像レイヤー1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      repeatx = false,
      repeaty = false,
      properties = {}
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "floors",
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
          name = "",
          type = "",
          shape = "polygon",
          x = 0.91347,
          y = 79.4719,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          polygon = {
            { x = 0, y = 0 },
            { x = 62.116, y = 31.9715 },
            { x = 62.116, y = 64.8564 },
            { x = 0, y = 30.1445 }
          },
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "polygon",
          x = 510.63,
          y = 165.338,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          polygon = {
            { x = 0, y = 0 },
            { x = -60.289, y = 28.3176 },
            { x = -61.2025, y = 60.289 },
            { x = 0, y = 30.1445 }
          },
          properties = {}
        },
        {
          id = 5,
          name = "",
          type = "",
          shape = "polygon",
          x = 512.457,
          y = 260.339,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          polygon = {
            { x = 0, y = 0 },
            { x = -63.9429, y = 30.1445 },
            { x = -64.8564, y = 63.0294 },
            { x = -2.74041, y = 29.231 }
          },
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "",
          shape = "polygon",
          x = 0.91347,
          y = 346.205,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          polygon = {
            { x = 0, y = 0 },
            { x = 62.116, y = 29.231 },
            { x = 60.289, y = 59.3756 },
            { x = -0.91347, y = 31.058 }
          },
          properties = {}
        },
        {
          id = 20,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0.91347,
          y = 481.399,
          width = 509.716,
          height = 30.1445,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 49,
          name = "",
          type = "",
          shape = "rectangle",
          x = 63.9429,
          y = 376.35,
          width = 312.406,
          height = 31.058,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 50,
          name = "",
          type = "",
          shape = "rectangle",
          x = 418.456,
          y = 376.35,
          width = 31.058,
          height = 31.058,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 51,
          name = "",
          type = "",
          shape = "rectangle",
          x = 64.8564,
          y = 290.483,
          width = 36.5388,
          height = 31.058,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 52,
          name = "",
          type = "",
          shape = "rectangle",
          x = 146.155,
          y = 290.483,
          width = 304.186,
          height = 31.9715,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 56,
          name = "",
          type = "",
          shape = "rectangle",
          x = 65.7698,
          y = 194.569,
          width = 327.022,
          height = 30.1445,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 57,
          name = "",
          type = "",
          shape = "rectangle",
          x = 64.8564,
          y = 109.616,
          width = 227.454,
          height = 31.9715,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 58,
          name = "",
          type = "",
          shape = "rectangle",
          x = 341.638,
          y = 109.616,
          width = 105.049,
          height = 33.7984,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 59,
          name = "",
          type = "",
          shape = "rectangle",
          x = 194.569,
          y = 28.3176,
          width = 61.2025,
          height = 31.9715,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 60,
          name = "",
          type = "",
          shape = "rectangle",
          x = 128.799,
          y = 29.231,
          width = 17.3559,
          height = 30.1445,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 61,
          name = "",
          type = "",
          shape = "rectangle",
          x = 423.85,
          y = -86.7797,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 6,
      name = "objects",
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
          id = 35,
          name = "",
          type = "",
          shape = "rectangle",
          x = 368.1,
          y = 489.649,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 2,
          visible = true,
          properties = {}
        },
        {
          id = 36,
          name = "",
          type = "",
          shape = "rectangle",
          x = 93.1454,
          y = 389.166,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 2,
          visible = true,
          properties = {}
        },
        {
          id = 53,
          name = "",
          type = "",
          shape = "rectangle",
          x = 383.629,
          y = 300.559,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 2,
          visible = true,
          properties = {}
        },
        {
          id = 54,
          name = "",
          type = "",
          shape = "rectangle",
          x = 284.974,
          y = 201.905,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 2,
          visible = true,
          properties = {}
        },
        {
          id = 55,
          name = "",
          type = "",
          shape = "rectangle",
          x = 139.732,
          y = 116.952,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 2,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 8,
      name = "doors",
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
          id = 62,
          name = "",
          type = "",
          shape = "rectangle",
          x = 192.787,
          y = 38.7707,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 7,
      name = "player",
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
          id = 46,
          name = "",
          type = "",
          shape = "rectangle",
          x = 47.4719,
          y = 479.6,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 1,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
