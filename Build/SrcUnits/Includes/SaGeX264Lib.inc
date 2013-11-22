type
	x264_int = LongInt;
	int64_t = Int64;
	x264_unsigned_int = LongWOrd;
	uint32_t = LongWord;
	x264_char = char;
	uint8_t = byte;
	x264_float = single;
	x264_pchar = ^ x264_char;
	puint8_t = ^ uint8_t;
	x264_double = real;


	x264_t = System.THandle;

	px264_param_t = ^ x264_param_t;
	x264_zone_t=RECORD
    i_start, i_end:x264_int; (* range of frame numbers *)
    b_force_qp:x264_int; (* whether to use qp vs bitrate factor *)
    i_qp: x264_int;
    f_bitrate_factor : x264_float;
    param: px264_param_t;
    end;

(* The data within the payload is already NAL-encapsulated; the ref_idc and type
 * are merely in the struct for easy access by the calling application.
 * All data returned in an x264_nal_t, including the data in p_payload, is no longer
 * valid after the next call to x264_encoder_encode.  Thus it must be used or copied
 * before calling x264_encoder_encode or x264_encoder_headers again. *)
	x264_nal_t=record

    i_ref_idc:x264_int;  (* nal_priority_e *)
    i_type:x264_int;     (* nal_unit_type_e *)
    b_long_startcode:x264_int;
    i_first_mb: x264_int; (* If this NAL is a slice, the index of the first MB in the slice. *)
    i_last_mb:x264_int;  (* If this NAL is a slice, the index of the last MB in the slice. *)

    (* Size of payload in bytes. *)
    i_payload:x264_int;
    (* If param->b_annexb is set, Annex-B bytestream with startcode.
     * Otherwise, startcode is replaced with a 4-byte size.
     * This size is the size used in mp4/similar muxing; it is equal to i_payload-4 *)
    p_payload:puint8_t;
	end;
//void (*nalu_process) ( x264_t *h, x264_nal_t *nal );
	x264_p_x264_nal_t = ^ x264_nal_t;
	
	
	x264_hrd_t=record
    cpb_initial_arrival_time:x264_double;
     cpb_final_arrival_time:x264_double;
     cpb_removal_time:x264_double;

     dpb_output_time:x264_double;
	end;
	
	x264_sei_payload_t = record
		 payload_size:x264_int;
		payload_type:x264_int;
		payload:puint8_t;
		end;
	
	x264_sei_t=record
		num_payloads:x264_int;
		payloads:^x264_sei_payload_t;
		(* In: optional callback to free each payload AND x264_sei_payload_t when used. *)
		//void (*sei_free)( void* );
		sei_free:function ():Pointer;
		end;

	 x264_image_t = record
		i_csp:x264_int;       (* Colorspace *)
		i_plane:x264_int;     (* Number of image planes *)
		i_stride:array[0..3] of x264_int; (* Strides for each plane *)
		plane:array[0..3] of puint8_t;   (* Pointers to each plane *)
		end;

	x264_image_properties_t = record
		(* In: an array of quantizer offsets to be applied to this image during encoding.
		 *     These are added on top of the decisions made by x264.
		 *     Offsets can be fractional; they are added before QPs are rounded to integer.
		 *     Adaptive quantization must be enabled to use this feature.  Behavior if quant
		 *     offsets differ between encoding passes is undefined.
		 *
		 *     Array contains one offset per macroblock, in raster scan order.  In interlaced
		 *     mode, top-field MBs and bottom-field MBs are interleaved at the row level. *)
		quant_offsets:^x264_float;
		(* In: optional callback to free quant_offsets when used.
		 *     Useful if one wants to use a different quant_offset array for each frame. *)
		//void (*quant_offsets_free)( void* );
		quant_offsets_free:function():pointer;
		(* Out: SSIM of the the frame luma (if x264_param_t.b_ssim is set) *)
		f_ssim:x264_double;
		(* Out: Average PSNR of the frame (if x264_param_t.b_psnr is set) *)
		f_psnr_avg:x264_double;
		(* Out: PSNR of Y, U, and V (if x264_param_t.b_psnr is set) *)
		f_psnr:array[0..2] of x264_double;
		end;
	
	
	x264_param_t=record
			(* CPU flags *)
		cpu:              x264_unsigned_int;
		i_threads:        x264_int;          (* encode multiple frames in parallel *)
		b_sliced_threads: x264_int;          (* Whether to use slice-based threading. *)
		b_deterministic:  x264_int;          (* whether to allow non-deterministic optimizations when threaded *)
		b_cpu_independent:x264_int;          (* force canonical behavior rather than cpu-dependent optimal algorithms *)
		i_sync_lookahead: x264_int;          (* threaded lookahead buffer *)
		
			(* Video Properties *)
		i_width:       x264_int;
		i_height:      x264_int;
		i_csp:         x264_int;         (* CSP of encoded bitstream *)
		i_level_idc:   x264_int;
		i_frame_total: x264_int;         (* number of frames to encode if known, else 0 *)
		
		(* NAL HRD
		 * Uses Buffering and Picture Timing SEIs to signal HRD
		 * The HRD in H.264 was not designed with VFR in mind.
		 * It is therefore not recommendeded to use NAL HRD with VFR.
		 * Furthermore, reconfiguring the VBV (via x264_encoder_reconfig)
		 * will currently generate invalid HRD. *)
		i_nal_hrd:     x264_int;
		
		vui:record 
				(* they will be reduced to be 0 < x <= 65535 and prime *)
			i_sar_height: x264_int;
			i_sar_width:  x264_int;

			i_overscan:   x264_int;    (* 0=undef, 1=no overscan, 2=overscan *)

			(* see h264 annex E for the values of the following *)
			i_vidformat:  x264_int;
			b_fullrange:  x264_int;
			i_colorprim:  x264_int;
			i_transfer:   x264_int;
			i_colmatrix:  x264_int;
			i_chroma_loc: x264_int;    (* both top & bottom *)
			end;
			
			(* Bitstream parameters *)
		i_frame_reference:    x264_int;     (* Maximum number of reference frames *)
		i_dpb_size:           x264_int;     (* Force a DPB size larger than that implied by B-frames and reference frames.
											 * Useful in combination with interactive error resilience. *)
		i_keyint_max:         x264_int;     (* Force an IDR keyframe at this interval *)
		i_keyint_min:         x264_int;     (* Scenecuts closer together than this are coded as I, not IDR. *)
		i_scenecut_threshold: x264_int;     (* how aggressively to insert extra I frames *)
		b_intra_refresh:      x264_int;     (* Whether or not to use periodic intra refresh instead of IDR frames. *)

		i_bframe:             x264_int;   (* how many b-frame between 2 references pictures *)
		i_bframe_adaptive:    x264_int;
		i_bframe_bias:        x264_int;
		i_bframe_pyramid:     x264_int;   (* Keep some B-frames as references: 0=off, 1=strict hierarchical, 2=normal *)
		b_open_gop:           x264_int;
		b_bluray_compat:      x264_int;

		b_deblocking_filter:  x264_int;
		i_deblocking_filter_alphac0: x264_int;    (* [-6, 6] -6 light filter, 6 strong *)
		i_deblocking_filter_beta: x264_int;       (* [-6, 6]  idem *)

		b_cabac: x264_int;
		i_cabac_init_idc: x264_int;

		b_interlaced: x264_int;
		b_constrained_intra: x264_int;

		i_cqm_preset: x264_int;
		psz_cqm_file:^x264_char;      (* JM format *)
		cqm_4iy:array[0..15] of uint8_t;        (* used only if i_cqm_preset == X264_CQM_CUSTOM *)
		cqm_4py:array[0..15] of uint8_t;
		cqm_4ic:array[0..15] of uint8_t;
		cqm_4pc:array[0..15] of uint8_t;
		cqm_8iy:array[0..63] of uint8_t;
		cqm_8py:array[0..63] of uint8_t;
		cqm_8ic:array[0..63] of uint8_t;
		cqm_8pc:array[0..63] of uint8_t;

		(* Log *)
		pf_log:function (i_level:x264_int;const psz:x264_pchar;const va_list:x264_char):Pointer;
		//void        (*pf_log)( void *, int i_level, const char *psz, va_list );
		p_log_private: Pointer;
		i_log_level: x264_int;
		b_visualize: x264_int;
		b_full_recon:x264_int;   (* fully reconstruct frames, even when not necessary for encoding.  Implied by psz_dump_yuv *)
		psz_dump_yuv: ^x264_char;  (* filename for reconstructed frames *)

		(* Encoder analyser parameters *)
		analyse:record
		
			intra: x264_unsigned_int;     (* intra partitions *)
			inter: x264_unsigned_int;     (* inter partitions *)

			b_transform_8x8: x264_int;
			i_weighted_pred: x264_int; (* weighting for P-frames *)
			b_weighted_bipred: x264_int; (* implicit weighting for B-frames *)
			i_direct_mv_pred: x264_int; (* spatial vs temporal mv prediction *)
			i_chroma_qp_offset: x264_int;

			i_me_method: x264_int; (* motion estimation algorithm to use (X264_ME_* ) *)
			i_me_range: x264_int; (* integer pixel motion estimation search range (from predicted mv) *)
			i_mv_range: x264_int; (* maximum length of a mv (in pixels). -1 = auto, based on level *)
			i_mv_range_thread: x264_int; (* minimum space between threads. -1 = auto, based on number of threads. *)
			i_subpel_refine: x264_int; (* subpixel motion estimation quality *)
			b_chroma_me: x264_int; (* chroma ME for subpel and mode decision in P-frames *)
			b_mixed_references: x264_int; (* allow each mb partition to have its own reference number *)
			i_trellis: x264_int;  (* trellis RD quantization *)
			b_fast_pskip: x264_int; (* early SKIP detection on P-frames *)
			b_dct_decimate: x264_int; (* transform coefficient thresholding on P-frames *)
			i_noise_reduction: x264_int; (* adaptive pseudo-deadzone *)
			f_psy_rd: x264_float; (* Psy RD strength *)
			f_psy_trellis: x264_float; (* Psy trellis strength *)
			b_psy: x264_int; (* Toggle all psy optimizations *)

			(* the deadzone size that will be used in luma quantization *)
			i_luma_deadzone:array[0..1] of x264_int; (* {inter, intra} *)

			b_psnr: x264_int;    (* compute and print PSNR stats *)
			b_ssim: x264_int;    (* compute and print SSIM stats *)
			end;

		(* Rate control parameters *)
		rc:
			record
			i_rc_method: x264_int;    (* X264_RC_* *)

			i_qp_constant: x264_int;  (* 0 to (51 + 6*(x264_bit_depth-8)). 0=lossless *)
			i_qp_min: x264_int;       (* min allowed QP value *)
			i_qp_max: x264_int;       (* max allowed QP value *)
			i_qp_step: x264_int;      (* max QP step between frames *)

			i_bitrate: x264_int;
			f_rf_constant: x264_float;  (* 1pass VBR, nominal QP *)
			f_rf_constant_max: x264_float;  (* In CRF mode, maximum CRF as caused by VBV *)
			f_rate_tolerance: x264_float;
			i_vbv_max_bitrate: x264_int;
			i_vbv_buffer_size: x264_int;
			f_vbv_buffer_init: x264_float; (* <=1: fraction of buffer_size. >1: kbit *)
			f_ip_factor: x264_float;
			f_pb_factor: x264_float;

			i_aq_mode: x264_int;      (* psy adaptive QP. (X264_AQ_* ) *)
			f_aq_strength: x264_float;
			b_mb_tree: x264_int;      (* Macroblock-tree ratecontrol. *)
			i_lookahead: x264_int;

			(* 2pass *)
			b_stat_write: x264_int;   (* Enable stat writing in psz_stat_out *)
			psz_stat_out: x264_pchar;
			b_stat_read: x264_int;    (* Read stat from psz_stat_in and use it *)
			psz_stat_in: x264_pchar;

			(* 2pass params (same as ffmpeg ones) *)
			f_qcompress: x264_float;    (* 0.0 => cbr, 1.0 => constant qp *)
			f_qblur: x264_float;        (* temporally blur quants *)
			f_complexity_blur: x264_float; (* temporally blur complexity *)
			zones:^x264_zone_t;         (* ratecontrol overrides *)
			i_zones: x264_int;        (* number of zone_t's *)
			psz_zones:x264_pchar;     (* alternate method of specifying zones *)
			end;

		(* Cropping Rectangle parameters: added to those implicitly defined by
		   non-mod16 video resolutions. *)
		crop_rect:record
		
			i_left:x264_unsigned_int;
			i_top:x264_unsigned_int;
			i_right:x264_unsigned_int;
			i_bottom:x264_unsigned_int;
		 end;

		(* frame packing arrangement flag *)
		i_frame_packing:x264_int;

		(* Muxing parameters *)
		b_aud:x264_int;                  (* generate access unit delimiters *)
		b_repeat_headers:x264_int;       (* put SPS/PPS before each keyframe *)
		b_annexb:x264_int;               (* if set, place start codes (4 bytes) before NAL units,
									 * otherwise place size (4 bytes) before NAL units. *)
		i_sps_id:x264_int;               (* SPS and PPS id number *)
		b_vfr_input:x264_int;            (* VFR input.  If 1, use timebase and timestamps for ratecontrol purposes.
									 * If 0, use fps only. *)
		b_pulldown:x264_int;             (* use explicity set timebase for CFR *)
		i_fps_num:uint32_t ;
		i_fps_den:uint32_t ;
		i_timebase_num:uint32_t ;    (* Timebase numerator *)
		i_timebase_den:uint32_t ;    (* Timebase denominator *)

		b_tff:x264_int;

		(* Pulldown:
		 * The correct pic_struct must be passed with each input frame.
		 * The input timebase should be the timebase corresponding to the output framerate. This should be constant.
		 * e.g. for 3:2 pulldown timebase should be 1001/30000
		 * The PTS passed with each frame must be the PTS of the frame after pulldown is applied.
		 * Frame doubling and tripling require b_vfr_input set to zero (see H.264 Table D-1)
		 *
		 * Pulldown changes are not clearly defined in H.264. Therefore, it is the calling app's responsibility to manage this.
		 *)

		b_pic_struct:x264_int;

		(* Fake Interlaced.
		 *
		 * Used only when b_interlaced=0. Setting this flag makes it possible to flag the stream as PAFF interlaced yet
		 * encode all frames progessively. It is useful for encoding 25p and 30p Blu-Ray streams.
		 *)

		 b_fake_interlaced:x264_int;

		(* Slicing parameters *)
		i_slice_max_size:x264_int;    (* Max size per slice in bytes; includes estimated NAL overhead. *)
		i_slice_max_mbs:x264_int;     (* Max number of MBs per slice; overrides i_slice_count. *)
		i_slice_count:x264_int;       (* Number of slices per frame: forces rectangular slices. *)

		(* Optional callback for freeing this x264_param_t when it is done being used.
		 * Only used when the x264_param_t sits in memory for an indefinite period of time,
		 * i.e. when an x264_param_t is passed to x264_t in an x264_picture_t or in zones.
		 * Not used when x264_encoder_reconfig is called directly. *)
		 param_free : function ():Pointer;
		//void (*param_free)( void* );

		(* Optional low-level callback for low-latency encoding.  Called for each output NAL unit
		 * immediately after the NAL unit is finished encoding.  This allows the calling application
		 * to begin processing video data (e.g. by sending packets over a network) before the frame
		 * is done encoding.
		 *
		 * This callback MUST do the following in order to work correctly:
		 * 1) Have available an output buffer of at least size nal->i_payload*3/2 + 5 + 16.
		 * 2) Call x264_nal_encode( h, dst, nal ), where dst is the output buffer.
		 * After these steps, the content of nal is valid and can be used in the same way as if
		 * the NAL unit were output by x264_encoder_encode.
		 *
		 * This does not need to be synchronous with the encoding process: the data pointed to
		 * by nal (both before and after x264_nal_encode) will remain valid until the next
		 * x264_encoder_encode call.  The callback must be re-entrant.
		 *
		 * This callback does not work with frame-based threads; threads must be disabled
		 * or sliced-threads enabled.  This callback also does not work as one would expect
		 * with HRD -- since the buffering period SEI cannot be calculated until the frame
		 * is finished encoding, it will not be sent via this callback.
		 *
		 * Note also that the NALs are not necessarily returned in order when sliced threads is
		 * enabled.  Accordingly, the variable i_first_mb and i_last_mb are available in
		 * x264_nal_t to help the calling application reorder the slices if necessary.
		 *
		 * When this callback is enabled, x264_encoder_encode does not return valid NALs;
		 * the calling application is expected to acquire all output NALs through the callback.
		 *
		 * It is generally sensible to combine this callback with a use of slice-max-mbs or
		 * slice-max-size. *)
		 nalu_process:procedure (h:x264_t;nal:x264_p_x264_nal_t);
		//void (*nalu_process) ( x264_t *h, x264_nal_t *nal );
		end;

	
	x264_picture_t=record
    (* In: force picture type (if not auto)
     *     If x264 encoding parameters are violated in the forcing of picture types,
     *     x264 will correct the input picture type and log a warning.
     *     The quality of frametype decisions may suffer if a great deal of fine-grained
     *     mixing of auto and forced frametypes is done.
     * Out: type of the picture encoded *)
    i_type:x264_int;
    (* In: force quantizer for != X264_QP_AUTO *)
    i_qpplus1:x264_int;
    (* In: pic_struct, for pulldown/doubling/etc...used only if b_pic_struct=1.
     *     use pic_struct_e for pic_struct inputs
     * Out: pic_struct element associated with frame *)
    i_pic_struct:x264_int;
    (* Out: whether this frame is a keyframe.  Important when using modes that result in
     *

 SEI recovery points being used instead of IDR frames. *)
    b_keyframe:x264_int;
    (* In: user pts, Out: pts of encoded picture (user)*)
    i_pts:int64_t;
    (* Out: frame dts. When the pts of the first frame is close to zero,
     *      initial frames may have a negative dts which must be dealt with by any muxer *)
    i_dts:int64_t;
    (* In: custom encoding parameters to be set from this frame forwards
           (in coded order, not display order). If NULL, continue using
           parameters from the previous frame.  Some parameters, such as
           aspect ratio, can only be changed per-GOP due to the limitations
           of H.264 itself; in this case, the caller must force an IDR frame
           if it needs the changed parameter to apply immediately. *)
    param:^x264_param_t;
    (* In: raw image data *)
    (* Out: reconstructed image data.  x264 may skip part of the reconstruction process,
            e.g. deblocking, in frames where it isn't necessary.  To force complete
            reconstruction, at a small speed cost, set b_full_recon. *)
    img:x264_image_t;
    (* In: optional information to modify encoder decisions for this frame
     * Out: information about the encoded frame *)
    prop:x264_image_properties_t;
    (* Out: HRD timing information. Output only when i_nal_hrd is set. *)
    hrd_timing:x264_hrd_t;
    (* In: arbitrary user SEI (e.g subtitles, AFDs) *)
    extra_sei:x264_sei_t;
    (* private user data. copied from input to output frames. *)
    opaque:Pointer;
end;

function x264_picture_alloc( var pic:x264_picture_t; i_csp:x264_int;  i_width:x264_int;  i_height:x264_int ):x264_int; external 'x264vfw.dll';
