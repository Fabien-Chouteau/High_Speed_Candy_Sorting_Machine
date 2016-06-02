with HAL.Bitmap; use HAL.Bitmap;
with OpenMV;
with OpenMV.LCD_Shield;
with OpenMV.Sensor;
with Color_Detection;

with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);

procedure Main is
begin
   OpenMV.Initialize_LEDs;
   OpenMV.Set_RGB_LED (OpenMV.White);
   OpenMV.LCD_Shield.Initialize;
   OpenMV.Sensor.Initialize;

   OpenMV.LCD_Shield.Get_Bitmap.Fill (Black);
   Draw_Rect (Buffer => OpenMV.LCD_Shield.Get_Bitmap,
              Color  => White,
              X      => 10,
              Y      => 10,
              Width  => OpenMV.LCD_Shield.Get_Bitmap.Width - 11,
              Height => OpenMV.LCD_Shield.Get_Bitmap.Height - 11);

   OpenMV.LCD_Shield.Display;

   Color_Detection.Initialize;

   loop
      OpenMV.Sensor.Snapshot (OpenMV.LCD_Shield.Get_Bitmap);

      Color_Detection.Filter_Image (OpenMV.LCD_Shield.Get_Bitmap);

      OpenMV.LCD_Shield.Display;
   end loop;
end Main;
