PRJ=DE0_HSP_Example

QPF := $(PRJ).qpf
QSF := $(PRJ).qsys
QSD := $(PRJ)

QIP_FILE := $(QSD)/synthesis/$(PRJ).qip
SOF_FILE := $(PRJ).sof

.PHONY: quartus_edit
quartus_edit:
	quartus $(QPF) &

.PHONY: qsys_edit
qsys_edit:
	qsys-edit $(QSF) &

.PHONY: qsys_generate
qsys_generate: $(QIP_FILE)

.PHONY: quartus_generate
quartus_generate:  $(SOF_FILE)


$(QIP_FILE): $(QSF)
	qsys-generate $(QSF) --synthesis=VERILOG --output-directory=$(QSD)

$(SOF_FILE): $(QIP_FILE)
	quartus_sh --flow compile  $(QPF)

clean:
	rm -rf 	db \
			hps_isw_handoff \
			incremental_db \
	        c5_pin_model_dump.txt \
	        hps_sdram_p0_all_pins.txt \
	        hps_sdram_p0_summary.csv \
	        DE0_HSP_Example_assignment_defaults.qdf \
			.qsys_edit \
	  		$(QSD) \
			$(SOF_FILE) \
			*.rpt \
			*.done \
			*.smsg \
			*.summary \
			*.htm \
			*.sopcinfo \
			*.sdl \
			*.pin \
			*.qws \
			*.sld \
			*.jdi 



