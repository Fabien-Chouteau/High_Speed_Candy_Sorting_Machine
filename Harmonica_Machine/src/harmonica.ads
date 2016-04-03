with Ada.Real_Time; use Ada.Real_Time;
with STM32.GPIO; use STM32.GPIO;
with STM32.Device; use STM32.Device;

package Harmonica is

   C     : GPIO_Point renames PD12;
   E     : GPIO_Point renames PD13;
   G     : GPIO_Point renames PD14;
   Low_C : GPIO_Point renames PD15;

   procedure Init;

   procedure Play (Notes : GPIO_Points; Len : Time_Span);
   procedure Play (Note : GPIO_Point; Len : Time_Span);
   procedure Silence (Len : Time_Span);
end Harmonica;
