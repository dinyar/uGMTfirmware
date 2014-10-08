

 
 
 

 



window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /phi_extrapolation_mem_tb/status
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/CLKA
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/ADDRA
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/DINA
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/WEA
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/DOUTA
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/CLKB
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/ADDRB
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/DINB
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/WEB
      waveform add -signals /phi_extrapolation_mem_tb/phi_extrapolation_mem_synth_inst/bmg_port/DOUTB

console submit -using simulator -wait no "run"
