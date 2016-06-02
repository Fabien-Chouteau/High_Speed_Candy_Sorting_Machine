with HAL;   use HAL;
with Image; use Image;
with HAL.Bitmap; use HAL.Bitmap;

package Color_Detection is

   procedure Initialize;
   function Initialized return Boolean;

   function Pixel_To_Candy_Color (Pix : Short) return Candy_Colors
     with Pre => Initialized;

   procedure Filter_Image (BM : Bitmap_Buffer'Class);

end Color_Detection;
