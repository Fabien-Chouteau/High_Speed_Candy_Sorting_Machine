with OpenMV;
with OpenMV.LCD_Shield;
with OpenMV.Sensor;
with OpenMV.Image;

with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);

procedure Main is
begin
   OpenMV.Initialize_LEDs;
   OpenMV.Set_RGB_LED (OpenMV.White);
   OpenMV.LCD_Shield.Initialize;
   OpenMV.Sensor.Initialize;
   loop
      OpenMV.Sensor.Snapshot;
      OpenMV.Image.Test;
      OpenMV.LCD_Shield.Display;
   end loop;
end Main;
