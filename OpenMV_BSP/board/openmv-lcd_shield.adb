with ST7735R;      use ST7735R;
with STM32.Device;
with STM32.GPIO;
with OpenMV;

package body OpenMV.LCD_Shield is

   LCD_RST : STM32.GPIO.GPIO_Point renames Shield_PWM1;
   LCD_RS  : STM32.GPIO.GPIO_Point renames Shield_PWM2;
   LCD_CS  : STM32.GPIO.GPIO_Point renames Shield_SEL;
   All_Points  : constant STM32.GPIO.GPIO_Points := (LCD_RS, LCD_CS, LCD_RST);

   LCD_Driver : ST7735R_Device (Port => Shield_SPI'Access,
                                CS   => LCD_CS'Access,
                                RS   => LCD_RS'Access,
                                RST  => LCD_RST'Access);
   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      GPIO_Conf : STM32.GPIO.GPIO_Port_Configuration;
   begin

      --  Initalize shield SPI port
      Initialize_SPI;

      STM32.Device.Enable_Clock (All_Points);

      GPIO_Conf.Mode        := STM32.GPIO.Mode_Out;
      GPIO_Conf.Output_Type := STM32.GPIO.Push_Pull;
      GPIO_Conf.Speed       := STM32.GPIO.Speed_100MHz;
      GPIO_Conf.Resistors   := STM32.GPIO.Floating;

      STM32.GPIO.Configure_IO (All_Points, GPIO_Conf);

      LCD_Driver.Initialize;

      LCD_Driver.Set_Memory_Data_Access
        (Color_Order         => RGB_Order,
         Vertical            => Vertical_Refresh_Top_Bottom,
         Horizontal          => Horizontal_Refresh_Left_Right,
         Row_Addr_Order      => Row_Address_Bottom_Top,
         Column_Addr_Order   => Column_Address_Right_Left,
         Row_Column_Exchange => False);

      LCD_Driver.Set_Pixel_Format (Pixel_16bits);


      LCD_Driver.Set_Frame_Rate_Normal (RTN         => 16#01#,
                             Front_Porch => 16#2C#,
                             Back_Porch  => 16#2D#);
      LCD_Driver.Set_Frame_Rate_Idle (RTN         => 16#01#,
                                      Front_Porch => 16#2C#,
                                      Back_Porch  => 16#2D#);
      LCD_Driver.Set_Frame_Rate_Partial_Full (RTN_Part         => 16#01#,
                                              Front_Porch_Part => 16#2C#,
                                              Back_Porch_Part  => 16#2D#,
                                              RTN_Full         => 16#01#,
                                              Front_Porch_Full => 16#2C#,
                                   Back_Porch_Full  => 16#2D#);
      LCD_Driver.Set_Inversion_Control (Normal       => Line_Inversion,
                                        Idle         => Line_Inversion,
                                        Full_Partial => Line_Inversion);
      LCD_Driver.Set_Power_Control_1 (AVDD => 2#101#,    --  5
                                      VRHP => 2#0_0010#, --  4.6
                                      VRHN => 2#0_0010#, --  -4.6
                                      MODE => 2#10#);    --  AUTO

      LCD_Driver.Set_Power_Control_2 (VGH25 => 2#11#,  --  2.4
                                      VGSEL => 2#01#,  --  3*AVDD
                                      VGHBT => 2#01#); --  -10

      LCD_Driver.Set_Power_Control_3 (16#0A#, 16#00#);
      LCD_Driver.Set_Power_Control_4 (16#8A#, 16#2A#);
      LCD_Driver.Set_Power_Control_5 (16#8A#, 16#EE#);
      LCD_Driver.Set_Vcom (16#E#);

      LCD_Driver.Set_Address (X_Start => 0,
                              X_End   => 127,
                              Y_Start => 0,
                              Y_End   => 159);
      LCD_Driver.Turn_On;
   end Initialize;

   -------------
   -- Display --
   -------------

   procedure Display is
   begin
      Set_Address (LCD_Driver,
                   X_Start => 0,
                   X_End   => 127,
                   Y_Start => 0,
                   Y_End   => 159);
      LCD_Driver.Write_Raw_Pixels (FB.Data.all);
   end Display;

end OpenMV.LCD_Shield;
