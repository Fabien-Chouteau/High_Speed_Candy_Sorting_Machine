with HAL;   use HAL;
with Image; use Image;
with HAL.Bitmap; use HAL.Bitmap;

package Color_Detection is

   procedure Initialize;
   function Initialized return Boolean;

   function Pixel_To_Candy_Color (Pix : Short) return Candy_Colors
     with Pre => Initialized;

   function Filter_Image (BM : Bitmap_Buffer'Class;
                          Region_X, Region_Y,
                          Region_W, Region_H : Integer := 0)
                          return Candy_Colors
     with Pre => Initialized and then
     Region_X in 0 .. BM.Width - 1 and then
     Region_Y in 0 .. BM.Height - 1 and then
     Region_X + Region_W in 0 .. BM.Width - 1 and then
     Region_Y + Region_H in 0 .. BM.Width - 1;

end Color_Detection;
