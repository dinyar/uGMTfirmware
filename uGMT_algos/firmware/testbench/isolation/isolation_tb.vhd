library std;
use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.GMTTypes.all;
use work.tb_helpers.all;
use STD.TEXTIO.all;

entity testbench is
end testbench;

architecture behavior of testbench is

  constant verbose : boolean := false;

  constant div240          : integer   := 12;
  constant div40           : integer   := 2;
  constant half_period_240 : time      := 25000 ps / div240;
  constant half_period_40  : time      := 6*half_period_240;
  signal   clk240          : std_logic := '0';
  signal   clk40           : std_logic := '0';
  signal   rst             : std_logic := '0';

  signal iEnergies           : TCaloRegionEtaSlice_vector(27 downto 0);
  signal iMuonsB             : TGMTMu_vector(35 downto 0);
  signal iMuonsO             : TGMTMu_vector(35 downto 0);
  signal iMuonsF             : TGMTMu_vector(35 downto 0);
  signal iMuonsRPCb          : TGMTMuRPC_vector(3 downto 0);
  signal iMuonsRPCf          : TGMTMuRPC_vector(3 downto 0);
  signal iTracksB            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksO            : TGMTMuTracks_vector(11 downto 0);
  signal iTracksF            : TGMTMuTracks_vector(11 downto 0);
  signal iSortRanksB         : TSortRank10_vector(35 downto 0);
  signal iSortRanksO         : TSortRank10_vector(35 downto 0);
  signal iSortRanksF         : TSortRank10_vector(35 downto 0);
  signal iEmptyB             : std_logic_vector(35 downto 0);
  signal iEmptyO             : std_logic_vector(35 downto 0);
  signal iEmptyF             : std_logic_vector(35 downto 0);
  signal iIdxBitsB           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsO           : TIndexBits_vector(35 downto 0);
  signal iIdxBitsF           : TIndexBits_vector(35 downto 0);
  signal sIdxBits            : TIndexBits_vector(7 downto 0);
  signal sMuPt               : TMuonPT_vector(7 downto 0);

  signal oIsoBits             : TIsoBits_vector (7 downto 0);
  signal oSelectedEnergies    : TCaloArea_vector(7 downto 0);
  signal oSelectedCaloIdxBits : TCaloIndexBit_vector(7 downto 0);
  signal oExtrapolatedCoordsF : TSpatialCoordinate_vector(35 downto 0);
  signal oExtrapolatedCoordsO : TSpatialCoordinate_vector(35 downto 0);
  signal oExtrapolatedCoordsB : TSpatialCoordinate_vector(35 downto 0);
  signal oMuIdxBits           : TIndexBits_vector(7 downto 0);
  signal oMuPt               : TMuonPT_vector(7 downto 0);

begin

    uut : entity work.IsoAssignmentUnit
      port map (
        iEnergies            => iEnergies,
        iMuonsB              => iMuonsB,
        iMuonsO              => iMuonsO,
        iMuonsF              => iMuonsF,
        iMuIdxBits           => sIdxBits,
        iFinalMuPt           => sMuPt,
        oIsoBits             => oIsoBits,
        oFinalEnergies       => oSelectedEnergies,
        oFinalCaloIdxBits    => oSelectedCaloIdxBits,
        oExtrapolatedCoordsB => oExtrapolatedCoordsB,
        oExtrapolatedCoordsO => oExtrapolatedCoordsO,
        oExtrapolatedCoordsF => oExtrapolatedCoordsF,
        oMuIdxBits           => oMuIdxBits,
        oFinalMuPt           => oMuPt,
        clk                  => clk40,
        clk_ipb              => clk240,
        sinit                => rst,
        ipb_in.ipb_addr      => (others => '0'),
        ipb_in.ipb_wdata     => (others => '0'),
        ipb_in.ipb_strobe    => '0',
        ipb_in.ipb_write     => '0',
        ipb_out              => open
        );
    uut_sort : entity work.SortAndCancelUnit
      port map(
        iMuonsB                 => iMuonsB,
        iMuonsO                 => iMuonsO,
        iMuonsF                 => iMuonsF,
        iMuonsRPCb              => iMuonsRPCb,
        iMuonsRPCf              => iMuonsRPCf,
        iSortRanksRPCb          => (others => "0000000000"),
        iSortRanksRPCf          => (others => "0000000000"),
        iEmptyRPCb              => (others => '0'),
        iEmptyRPCf              => (others => '0'),
        iIdxBitsRPCb            => (others => "0000000"),
        iIdxBitsRPCf            => (others => "0000000"),
        iTracksB                => iTracksB,
        iTracksO                => iTracksO,
        iTracksF                => iTracksF,
        iSortRanksB             => iSortRanksB,
        iSortRanksO             => iSortRanksO,
        iSortRanksF             => iSortRanksF,
        iEmptyB                 => iEmptyB,
        iEmptyO                 => iEmptyO,
        iEmptyF                 => iEmptyF,
        iIdxBitsB               => iIdxBitsB,
        iIdxBitsO               => iIdxBitsO,
        iIdxBitsF               => iIdxBitsF,
        oIntermediateMuonsB     => open,
        oIntermediateMuonsO     => open,
        oIntermediateMuonsF     => open,
        oIntermediateSortRanksB => open,
        oIntermediateSortRanksO => open,
        oIntermediateSortRanksF => open,
        oIdxBits                => sIdxBits,
        oMuPt                   => sMuPt,
        oMuons                  => open,
        clk                     => clk40,
        clk_ipb                 => clk240,
        sinit                   => rst,
        ipb_in.ipb_addr         => (others => '0'),
        ipb_in.ipb_wdata        => (others => '0'),
        ipb_in.ipb_strobe       => '0',
        ipb_in.ipb_write        => '0',
        ipb_out                 => open
        );

  -- Clocks
  clk240 <= not clk240 after half_period_240;
  clk40  <= not clk40  after half_period_40;

  --  Test Bench Statements
  tb : process
    file F                        : text open read_mode is "ugmt_testfile.dat";
    file FO                       : text open write_mode is "../results/isolation_tb.results";
    variable L, LO                : line;
    variable caloEvent            : TGMTCaloEvent;
    variable muEvent              : TGMTMuEvent;
    constant ISO_LATENCY          : integer                        := 6;
    variable caloEvent_buffer     : TGMTCaloEvent_vec(ISO_LATENCY-1 downto 0);
    variable muEvent_buffer       : TGMTMuEvent_vec(ISO_LATENCY-1 downto 0);
    variable iEvent               : integer                        := 0;
    variable tmpError             : integer;
    variable cntError             : integer                        := 0;
    variable remainingEvents      : integer                        := ISO_LATENCY-2;
    variable vMuPt                : TMuonPT_vector(7 downto 0);
    variable vIsoBits             : TIsoBits_vector (7 downto 0);
    variable vSelectedEnergies    : TCaloArea_vector(7 downto 0);
    variable vSelectedCaloIdxBits : TCaloIndexBit_vector(7 downto 0);
    variable vExtrapolatedCoordsF : TSpatialCoordinate_vector(35 downto 0);
    variable vExtrapolatedCoordsO : TSpatialCoordinate_vector(35 downto 0);
    variable vExtrapolatedCoordsB : TSpatialCoordinate_vector(35 downto 0);
    variable vMuIdxBits           : TIndexBits_vector(7 downto 0);
    variable emu_id               : string(1 to 3) := "EMU";
    variable fw_id                : string(1 to 3) := "SIM";
    variable brl_id               : string(1 to 3) := "BRL";
    variable ovl_id               : string(1 to 3) := "OVL";
    variable fwd_id               : string(1 to 3) := "FWD";
  begin
        -- Reset event buffer
    for iEvent in muEvent_buffer'range loop
      muEvent_buffer(iEvent).iEvent := -1;
      caloEvent_buffer(iEvent).iEvent := -1;
      for iSlice in caloEvent_buffer(iEvent).energies'range loop
       for iEnergy in caloEvent_buffer(iEvent).energies(iSlice)'range loop
           caloEvent_buffer(iEvent).energies(iSlice)(iEnergy) := (others => '0');
       end loop; -- iEnergy
      end loop; -- iSlice
      for i in muEvent_buffer(iEvent).muons_brl'range loop
        muEvent_buffer(iEvent).muons_brl(i).phi    := "0000000000";
        muEvent_buffer(iEvent).muons_brl(i).eta    := "000000000";
        muEvent_buffer(iEvent).muons_brl(i).pt     := "000000000";
        muEvent_buffer(iEvent).muons_brl(i).qual   := "0000";
        muEvent_buffer(iEvent).muons_brl(i).sysign := "00";
        muEvent_buffer(iEvent).muons_ovl(i).phi    := "0000000000";
        muEvent_buffer(iEvent).muons_ovl(i).eta    := "000000000";
        muEvent_buffer(iEvent).muons_ovl(i).pt     := "000000000";
        muEvent_buffer(iEvent).muons_ovl(i).qual   := "0000";
        muEvent_buffer(iEvent).muons_ovl(i).sysign := "00";
        muEvent_buffer(iEvent).muons_fwd(i).phi    := "0000000000";
        muEvent_buffer(iEvent).muons_fwd(i).eta    := "000000000";
        muEvent_buffer(iEvent).muons_fwd(i).pt     := "000000000";
        muEvent_buffer(iEvent).muons_fwd(i).qual   := "0000";
        muEvent_buffer(iEvent).muons_fwd(i).sysign := "00";
        muEvent_buffer(iEvent).sortRanks_brl(i)    := "0000000000";
        muEvent_buffer(iEvent).sortRanks_ovl(i)    := "0000000000";
        muEvent_buffer(iEvent).sortRanks_fwd(i)    := "0000000000";
        muEvent_buffer(iEvent).empty_brl(i)        := '1';
        muEvent_buffer(iEvent).empty_ovl(i)        := '1';
        muEvent_buffer(iEvent).empty_fwd(i)        := '1';
        muEvent_buffer(iEvent).idxBits_brl(i)      := (others => '0');
        muEvent_buffer(iEvent).idxBits_ovl(i)      := (others => '0');
        muEvent_buffer(iEvent).idxBits_fwd(i)      := (others => '0');
      end loop;
      for i in muEvent_buffer(iEvent).expectedMuons'range loop
        muEvent_buffer(iEvent).expectedMuons(i).phi     := "0000000000";
        muEvent_buffer(iEvent).expectedMuons(i).eta     := "000000000";
        muEvent_buffer(iEvent).expectedMuons(i).pt      := "000000000";
        muEvent_buffer(iEvent).expectedMuons(i).qual    := "0000";
        muEvent_buffer(iEvent).expectedMuons(i).sysign  := "00";
        muEvent_buffer(iEvent).expectedIntMuB(i).phi    := "0000000000";
        muEvent_buffer(iEvent).expectedIntMuB(i).eta    := "000000000";
        muEvent_buffer(iEvent).expectedIntMuB(i).pt     := "000000000";
        muEvent_buffer(iEvent).expectedIntMuB(i).qual   := "0000";
        muEvent_buffer(iEvent).expectedIntMuB(i).sysign := "00";
        muEvent_buffer(iEvent).expectedIntMuO(i).phi    := "0000000000";
        muEvent_buffer(iEvent).expectedIntMuO(i).eta    := "000000000";
        muEvent_buffer(iEvent).expectedIntMuO(i).pt     := "000000000";
        muEvent_buffer(iEvent).expectedIntMuO(i).qual   := "0000";
        muEvent_buffer(iEvent).expectedIntMuO(i).sysign := "00";
        muEvent_buffer(iEvent).expectedIntMuF(i).phi    := "0000000000";
        muEvent_buffer(iEvent).expectedIntMuF(i).eta    := "000000000";
        muEvent_buffer(iEvent).expectedIntMuF(i).pt     := "000000000";
        muEvent_buffer(iEvent).expectedIntMuF(i).qual   := "0000";
        muEvent_buffer(iEvent).expectedIntMuF(i).sysign := "00";
        muEvent_buffer(iEvent).expectedSrtRnksB(i)      := (others => '0');
        muEvent_buffer(iEvent).expectedSrtRnksO(i)      := (others => '0');
        muEvent_buffer(iEvent).expectedSrtRnksF(i)      := (others => '0');
      end loop;  -- i
      for i in iTracksB'range loop
        for j in iTracksB(0)'range loop
          muEvent_buffer(iEvent).tracks_brl(i)(j).eta  := "000000000";
          muEvent_buffer(iEvent).tracks_brl(i)(j).phi  := "0000000000";
          muEvent_buffer(iEvent).tracks_brl(i)(j).qual := "0000";
          muEvent_buffer(iEvent).tracks_ovl(i)(j).eta  := "000000000";
          muEvent_buffer(iEvent).tracks_ovl(i)(j).phi  := "0000000000";
          muEvent_buffer(iEvent).tracks_ovl(i)(j).qual := "0000";
          muEvent_buffer(iEvent).tracks_fwd(i)(j).eta  := "000000000";
          muEvent_buffer(iEvent).tracks_fwd(i)(j).phi  := "0000000000";
          muEvent_buffer(iEvent).tracks_fwd(i)(j).qual := "0000";
        end loop;  -- j
      end loop;  -- i
    end loop;  -- event
    wait for 20*half_period_40;  -- wait until global set/reset completes
    while remainingEvents > 0 loop
      tmpError := 99999999;
      if not endfile(F) then
        ReadCaloEvent(F, iEvent, caloEvent);
        ReadMuEvent(F, iEvent, muEvent);
        ReadIdxBits(F); -- Dummy procedure.
        -- Filling uGMT
        iMuonsB     <= muEvent.muons_brl;
        iMuonsO     <= muEvent.muons_ovl;
        iMuonsF     <= muEvent.muons_fwd;
        iTracksB    <= muEvent.tracks_brl;
        iTracksO    <= muEvent.tracks_ovl;
        iTracksF    <= muEvent.tracks_fwd;
        iSortRanksB <= muEvent.sortRanks_brl;
        iSortRanksO <= muEvent.sortRanks_ovl;
        iSortRanksF <= muEvent.sortRanks_fwd;
        iEmptyB     <= muEvent.empty_brl;
        iEmptyO     <= muEvent.empty_ovl;
        iEmptyF     <= muEvent.empty_fwd;
        iIdxBitsB   <= muEvent.idxBits_brl;
        iIdxBitsO   <= muEvent.idxBits_ovl;
        iIdxBitsF   <= muEvent.idxBits_fwd;

        iEnergies <= caloEvent.energies;

        muEvent_buffer(0) := muEvent;
        caloEvent_buffer(0) := caloEvent;

      else
        remainingEvents := remainingEvents-1;
      end if;

      muEvent_buffer(ISO_LATENCY-1 downto 1)   := muEvent_buffer(ISO_LATENCY-2 downto 0);
      caloEvent_buffer(ISO_LATENCY-1 downto 1) := caloEvent_buffer(ISO_LATENCY-2 downto 0);
      vMuPt                                    := oMuPt;
      vSelectedEnergies                        := oSelectedEnergies;
      vSelectedCaloIdxBits                     := oSelectedCaloIdxBits;
      vExtrapolatedCoordsB                     := oExtrapolatedCoordsB;
      vExtrapolatedCoordsO                     := oExtrapolatedCoordsO;
      vExtrapolatedCoordsF                     := oExtrapolatedCoordsF;
      vMuIdxBits                               := oMuIdxBits;
      vIsoBits                                 := oIsoBits;

      ValidateIsolationOutput(vIsoBits, muEvent_buffer(ISO_LATENCY-1), FO, tmpError);
      cntError := cntError+tmpError;

      if verbose or (tmpError > 0) then
        if tmpError > 0 then
          write(LO, string'("@@@ ERROR in event "));
        else
          write(LO, string'("@@@ Dumping event "));
        end if;
        write(LO, muEvent_buffer(ISO_LATENCY-1).iEvent);
        writeline (FO, LO);

        DumpIsoBits(vIsoBits, FO, fw_id);
        DumpIsoBits(muEvent_buffer(ISO_LATENCY-1).expectedIsoBits, FO, emu_id);
        DumpFinalPt(vMuPt, FO);
        DumpMuIdxBits(vMuIdxBits, FO);
        DumpSelectedEnergies(vSelectedEnergies, FO);
        DumpCaloIdxBits(vSelectedCaloIdxBits, FO);
        DumpCaloEvent(caloEvent_buffer(ISO_LATENCY-1), FO);
        DumpEventMuons(muEvent_buffer(ISO_LATENCY-1), FO);
        DumpExtrapolatedCoordiantes(vExtrapolatedCoordsB, FO, brl_id);
        DumpExtrapolatedCoordiantes(vExtrapolatedCoordsO, FO, ovl_id);
        DumpExtrapolatedCoordiantes(vExtrapolatedCoordsF, FO, fwd_id);
        write(LO, string'(""));
        writeline (FO, LO);
      end if;


    wait for 25 ns;
    iEvent := iEvent+1;
  end loop;
  write(LO, string'("!!!!! Number of events with errors: "));
  write(LO, cntError);
  writeline(FO, LO);
  finish(0);
end process tb;
--  End Test Bench

end;
