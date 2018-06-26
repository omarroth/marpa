@[Link(ldflags: "`command -v pkg-config > /dev/null && pkg-config --libs libmarpa 2> /dev/null|| printf %s '-lmarpa'`")]
lib LibMarpa
  $marpa__debug_handler : (LibC::Char* -> LibC::Int)
  $marpa__debug_level : LibC::Int
  $marpa__out_of_memory : (-> Void*)
  $marpa_major_version : LibC::Int
  $marpa_micro_version : LibC::Int
  $marpa_minor_version : LibC::Int
  alias MarpaAssertionId = LibC::Int
  alias MarpaAvlTable = Void
  alias MarpaEarleme = LibC::Int
  alias MarpaEarleySetId = LibC::Int
  alias MarpaG = Void
  alias MarpaR = Void
  alias MarpaRank = LibC::Int
  alias MarpaRuleId = LibC::Int
  alias MarpaSymbolId = LibC::Int
  alias MarpaValue = Marpa_Value*
  fun marpa__default_debug_handler(format : LibC::Char*, ...) : LibC::Int
  fun marpa_b_ambiguity_metric(b : MarpaBocage) : LibC::Int
  fun marpa_b_is_null(b : MarpaBocage) : LibC::Int
  fun marpa_b_new(r : MarpaRecognizer, earley_set_id : MarpaEarleySetId) : MarpaBocage
  fun marpa_b_ref(b : MarpaBocage) : MarpaBocage
  fun marpa_b_unref(b : MarpaBocage)
  fun marpa_c_error(config : MarpaConfig*, p_error_string : LibC::Char*) : MarpaErrorCode
  fun marpa_c_init(config : MarpaConfig*) : LibC::Int
  fun marpa_check_version(required_major : LibC::Int, required_minor : LibC::Int, required_micro : LibC::Int) : MarpaErrorCode
  fun marpa_debug_handler_set(debug_handler : (LibC::Char* -> LibC::Int))
  fun marpa_debug_level_set(level : LibC::Int) : LibC::Int
  fun marpa_g_completion_symbol_activate(g : MarpaGrammar, sym_id : MarpaSymbolId, reactivate : LibC::Int) : LibC::Int
  fun marpa_g_default_rank(g : MarpaGrammar) : MarpaRank
  fun marpa_g_default_rank_set(g : MarpaGrammar, rank : MarpaRank) : MarpaRank
  fun marpa_g_error(g : MarpaGrammar, p_error_string : LibC::Char*) : MarpaErrorCode
  fun marpa_g_error_clear(g : MarpaGrammar) : MarpaErrorCode
  fun marpa_g_event(g : MarpaGrammar, event : MarpaEvent*, ix : LibC::Int) : MarpaEventType
  fun marpa_g_event_count(g : MarpaGrammar) : LibC::Int
  fun marpa_g_force_valued(g : MarpaGrammar) : LibC::Int
  fun marpa_g_has_cycle(g : MarpaGrammar) : LibC::Int
  fun marpa_g_highest_rule_id(g : MarpaGrammar) : LibC::Int
  fun marpa_g_highest_symbol_id(g : MarpaGrammar) : LibC::Int
  fun marpa_g_highest_zwa_id(g : MarpaGrammar) : MarpaAssertionId
  fun marpa_g_is_precomputed(g : MarpaGrammar) : LibC::Int
  fun marpa_g_new(configuration : MarpaConfig*) : MarpaGrammar
  fun marpa_g_nulled_symbol_activate(g : MarpaGrammar, sym_id : MarpaSymbolId, reactivate : LibC::Int) : LibC::Int
  fun marpa_g_precompute(g : MarpaGrammar) : LibC::Int
  fun marpa_g_prediction_symbol_activate(g : MarpaGrammar, sym_id : MarpaSymbolId, reactivate : LibC::Int) : LibC::Int
  fun marpa_g_ref(g : MarpaGrammar) : MarpaGrammar
  fun marpa_g_rule_is_accessible(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_is_loop(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_is_nullable(g : MarpaGrammar, ruleid : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_is_nulling(g : MarpaGrammar, ruleid : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_is_productive(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_is_proper_separation(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_length(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_lhs(g : MarpaGrammar, rule_id : MarpaRuleId) : MarpaSymbolId
  fun marpa_g_rule_new(g : MarpaGrammar, lhs_id : MarpaSymbolId, rhs_ids : MarpaSymbolId*, length : LibC::Int) : MarpaRuleId
  fun marpa_g_rule_null_high(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_rule_null_high_set(g : MarpaGrammar, rule_id : MarpaRuleId, flag : LibC::Int) : LibC::Int
  fun marpa_g_rule_rank(g : MarpaGrammar, rule_id : MarpaRuleId) : MarpaRank
  fun marpa_g_rule_rank_set(g : MarpaGrammar, rule_id : MarpaRuleId, rank : MarpaRank) : MarpaRank
  fun marpa_g_rule_rhs(g : MarpaGrammar, rule_id : MarpaRuleId, ix : LibC::Int) : MarpaSymbolId
  fun marpa_g_sequence_min(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_sequence_new(g : MarpaGrammar, lhs_id : MarpaSymbolId, rhs_id : MarpaSymbolId, separator_id : MarpaSymbolId, min : LibC::Int, flags : LibC::Int) : MarpaRuleId
  fun marpa_g_sequence_separator(g : MarpaGrammar, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_g_start_symbol(g : MarpaGrammar) : MarpaSymbolId
  fun marpa_g_start_symbol_set(g : MarpaGrammar, sym_id : MarpaSymbolId) : MarpaSymbolId
  fun marpa_g_symbol_is_accessible(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_completion_event(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_completion_event_set(g : MarpaGrammar, sym_id : MarpaSymbolId, value : LibC::Int) : LibC::Int
  fun marpa_g_symbol_is_counted(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_nullable(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_nulled_event(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_nulled_event_set(g : MarpaGrammar, sym_id : MarpaSymbolId, value : LibC::Int) : LibC::Int
  fun marpa_g_symbol_is_nulling(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_prediction_event(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_prediction_event_set(g : MarpaGrammar, sym_id : MarpaSymbolId, value : LibC::Int) : LibC::Int
  fun marpa_g_symbol_is_productive(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_start(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_terminal(g : MarpaGrammar, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_terminal_set(g : MarpaGrammar, sym_id : MarpaSymbolId, value : LibC::Int) : LibC::Int
  fun marpa_g_symbol_is_valued(g : MarpaGrammar, symbol_id : MarpaSymbolId) : LibC::Int
  fun marpa_g_symbol_is_valued_set(g : MarpaGrammar, symbol_id : MarpaSymbolId, value : LibC::Int) : LibC::Int
  fun marpa_g_symbol_new(g : MarpaGrammar) : MarpaSymbolId
  fun marpa_g_symbol_rank(g : MarpaGrammar, sym_id : MarpaSymbolId) : MarpaRank
  fun marpa_g_symbol_rank_set(g : MarpaGrammar, sym_id : MarpaSymbolId, rank : MarpaRank) : MarpaRank
  fun marpa_g_unref(g : MarpaGrammar)
  fun marpa_g_zwa_new(g : MarpaGrammar, default_value : LibC::Int) : MarpaAssertionId
  fun marpa_g_zwa_place(g : MarpaGrammar, zwaid : MarpaAssertionId, xrl_id : MarpaRuleId, rhs_ix : LibC::Int) : LibC::Int
  fun marpa_o_ambiguity_metric(o : MarpaOrder) : LibC::Int
  fun marpa_o_high_rank_only(o : MarpaOrder) : LibC::Int
  fun marpa_o_high_rank_only_set(o : MarpaOrder, flag : LibC::Int) : LibC::Int
  fun marpa_o_is_null(o : MarpaOrder) : LibC::Int
  fun marpa_o_new(b : MarpaBocage) : MarpaOrder
  fun marpa_o_rank(o : MarpaOrder) : LibC::Int
  fun marpa_o_ref(o : MarpaOrder) : MarpaOrder
  fun marpa_o_unref(o : MarpaOrder)
  fun marpa_r_alternative(r : MarpaRecognizer, token_id : MarpaSymbolId, value : LibC::Int, length : LibC::Int) : MarpaErrorCode
  fun marpa_r_clean(r : MarpaRecognizer) : MarpaEarleme
  fun marpa_r_completion_symbol_activate(r : MarpaRecognizer, sym_id : MarpaSymbolId, reactivate : LibC::Int) : LibC::Int
  fun marpa_r_current_earleme(r : MarpaRecognizer) : MarpaEarleme
  fun marpa_r_earleme(r : MarpaRecognizer, set_id : MarpaEarleySetId) : MarpaEarleme
  fun marpa_r_earleme_complete(r : MarpaRecognizer) : LibC::Int
  fun marpa_r_earley_item_warning_threshold(r : MarpaRecognizer) : LibC::Int
  fun marpa_r_earley_item_warning_threshold_set(r : MarpaRecognizer, threshold : LibC::Int) : LibC::Int
  fun marpa_r_earley_set_value(r : MarpaRecognizer, earley_set : MarpaEarleySetId) : LibC::Int
  fun marpa_r_earley_set_values(r : MarpaRecognizer, earley_set : MarpaEarleySetId, p_value : LibC::Int*, p_pvalue : Void**) : LibC::Int
  fun marpa_r_expected_symbol_event_set(r : MarpaRecognizer, symbol_id : MarpaSymbolId, value : LibC::Int) : LibC::Int
  fun marpa_r_furthest_earleme(r : MarpaRecognizer) : LibC::UInt
  fun marpa_r_is_exhausted(r : MarpaRecognizer) : LibC::Int
  fun marpa_r_latest_earley_set(r : MarpaRecognizer) : MarpaEarleySetId
  fun marpa_r_latest_earley_set_value_set(r : MarpaRecognizer, value : LibC::Int) : LibC::Int
  fun marpa_r_latest_earley_set_values_set(r : MarpaRecognizer, value : LibC::Int, pvalue : Void*) : LibC::Int
  fun marpa_r_new(g : MarpaGrammar) : MarpaRecognizer
  fun marpa_r_nulled_symbol_activate(r : MarpaRecognizer, sym_id : MarpaSymbolId, boolean : LibC::Int) : LibC::Int
  fun marpa_r_prediction_symbol_activate(r : MarpaRecognizer, sym_id : MarpaSymbolId, boolean : LibC::Int) : LibC::Int
  fun marpa_r_progress_item(r : MarpaRecognizer, position : LibC::Int*, origin : MarpaEarleySetId*) : MarpaRuleId
  fun marpa_r_progress_report_finish(r : MarpaRecognizer) : LibC::Int
  fun marpa_r_progress_report_reset(r : MarpaRecognizer) : LibC::Int
  fun marpa_r_progress_report_start(r : MarpaRecognizer, set_id : MarpaEarleySetId) : LibC::Int
  fun marpa_r_ref(r : MarpaRecognizer) : MarpaRecognizer
  fun marpa_r_start_input(r : MarpaRecognizer) : LibC::Int
  fun marpa_r_terminal_is_expected(r : MarpaRecognizer, symbol_id : MarpaSymbolId) : LibC::Int
  fun marpa_r_terminals_expected(r : MarpaRecognizer, buffer : LibC::Int*) : LibC::Int
  fun marpa_r_unref(r : MarpaRecognizer)
  fun marpa_r_zwa_default(r : MarpaRecognizer, zwaid : MarpaAssertionId) : LibC::Int
  fun marpa_r_zwa_default_set(r : MarpaRecognizer, zwaid : MarpaAssertionId, default_value : LibC::Int) : LibC::Int
  fun marpa_t_new(o : MarpaOrder) : MarpaTree
  fun marpa_t_next(t : MarpaTree) : LibC::Int
  fun marpa_t_parse_count(t : MarpaTree) : LibC::Int
  fun marpa_t_ref(t : MarpaTree) : MarpaTree
  fun marpa_t_unref(t : MarpaTree)
  fun marpa_v_new(t : MarpaTree) : MarpaValue
  fun marpa_v_ref(v : MarpaValue) : MarpaValue
  fun marpa_v_rule_is_valued(v : MarpaValue, rule_id : MarpaRuleId) : LibC::Int
  fun marpa_v_rule_is_valued_set(v : MarpaValue, rule_id : MarpaRuleId, status : LibC::Int) : LibC::Int
  fun marpa_v_step(v : MarpaValue) : MarpaStepType
  fun marpa_v_symbol_is_valued(v : MarpaValue, sym_id : MarpaSymbolId) : LibC::Int
  fun marpa_v_symbol_is_valued_set(v : MarpaValue, sym_id : MarpaSymbolId, status : LibC::Int) : LibC::Int
  fun marpa_v_unref(v : MarpaValue)
  fun marpa_v_valued_force(v : MarpaValue) : LibC::Int
  fun marpa_version(version : StaticArray(LibC::Int, 3)*) : MarpaErrorCode

  struct Marpa_Config
    t_is_ok : LibC::Int
    t_error : MarpaErrorCode
    t_error_string : LibC::Char*
  end

  struct MarpaEvent
    t_type : MarpaEventType
    t_value : LibC::Int
  end

  struct Marpa_Progress_Item
    t_rule_id : MarpaRuleId
    t_position : LibC::Int
    t_origin : LibC::Int
  end

  struct Marpa_Value
    t_step_type : MarpaStepType
    t_token_id : MarpaSymbolId
    t_token_value : LibC::Int
    t_rule_id : MarpaRuleId
    t_arg_0 : LibC::Int
    t_arg_n : LibC::Int
    t_result : LibC::Int
    t_token_start_ys_id : MarpaEarleySetId
    t_rule_start_ys_id : MarpaEarleySetId
    t_ys_id : MarpaEarleySetId
  end

  type MarpaBocage = Void*
  type MarpaConfig = Marpa_Config
  # type MarpaEvent = Marpa_Event
  type MarpaGrammar = Void*
  type MarpaOrder = Void*
  type MarpaRecognizer = Void*
  type MarpaTree = Void*

  enum MarpaErrorCode
    MARPA_ERR_NONE                           =  0
    MARPA_ERR_AHFA_IX_NEGATIVE               =  1
    MARPA_ERR_AHFA_IX_OOB                    =  2
    MARPA_ERR_ANDID_NEGATIVE                 =  3
    MARPA_ERR_ANDID_NOT_IN_OR                =  4
    MARPA_ERR_ANDIX_NEGATIVE                 =  5
    MARPA_ERR_BAD_SEPARATOR                  =  6
    MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED     =  7
    MARPA_ERR_COUNTED_NULLABLE               =  8
    MARPA_ERR_DEVELOPMENT                    =  9
    MARPA_ERR_DUPLICATE_AND_NODE             = 10
    MARPA_ERR_DUPLICATE_RULE                 = 11
    MARPA_ERR_DUPLICATE_TOKEN                = 12
    MARPA_ERR_YIM_COUNT                      = 13
    MARPA_ERR_YIM_ID_INVALID                 = 14
    MARPA_ERR_EVENT_IX_NEGATIVE              = 15
    MARPA_ERR_EVENT_IX_OOB                   = 16
    MARPA_ERR_GRAMMAR_HAS_CYCLE              = 17
    MARPA_ERR_INACCESSIBLE_TOKEN             = 18
    MARPA_ERR_INTERNAL                       = 19
    MARPA_ERR_INVALID_AHFA_ID                = 20
    MARPA_ERR_INVALID_AIMID                  = 21
    MARPA_ERR_INVALID_BOOLEAN                = 22
    MARPA_ERR_INVALID_IRLID                  = 23
    MARPA_ERR_INVALID_NSYID                  = 24
    MARPA_ERR_INVALID_LOCATION               = 25
    MARPA_ERR_INVALID_RULE_ID                = 26
    MARPA_ERR_INVALID_START_SYMBOL           = 27
    MARPA_ERR_INVALID_SYMBOL_ID              = 28
    MARPA_ERR_I_AM_NOT_OK                    = 29
    MARPA_ERR_MAJOR_VERSION_MISMATCH         = 30
    MARPA_ERR_MICRO_VERSION_MISMATCH         = 31
    MARPA_ERR_MINOR_VERSION_MISMATCH         = 32
    MARPA_ERR_NOOKID_NEGATIVE                = 33
    MARPA_ERR_NOT_PRECOMPUTED                = 34
    MARPA_ERR_NOT_TRACING_COMPLETION_LINKS   = 35
    MARPA_ERR_NOT_TRACING_LEO_LINKS          = 36
    MARPA_ERR_NOT_TRACING_TOKEN_LINKS        = 37
    MARPA_ERR_NO_AND_NODES                   = 38
    MARPA_ERR_NO_EARLEY_SET_AT_LOCATION      = 39
    MARPA_ERR_NO_OR_NODES                    = 40
    MARPA_ERR_NO_PARSE                       = 41
    MARPA_ERR_NO_RULES                       = 42
    MARPA_ERR_NO_START_SYMBOL                = 43
    MARPA_ERR_NO_TOKEN_EXPECTED_HERE         = 44
    MARPA_ERR_NO_TRACE_YIM                   = 45
    MARPA_ERR_NO_TRACE_YS                    = 46
    MARPA_ERR_NO_TRACE_PIM                   = 47
    MARPA_ERR_NO_TRACE_SRCL                  = 48
    MARPA_ERR_NULLING_TERMINAL               = 49
    MARPA_ERR_ORDER_FROZEN                   = 50
    MARPA_ERR_ORID_NEGATIVE                  = 51
    MARPA_ERR_OR_ALREADY_ORDERED             = 52
    MARPA_ERR_PARSE_EXHAUSTED                = 53
    MARPA_ERR_PARSE_TOO_LONG                 = 54
    MARPA_ERR_PIM_IS_NOT_LIM                 = 55
    MARPA_ERR_POINTER_ARG_NULL               = 56
    MARPA_ERR_PRECOMPUTED                    = 57
    MARPA_ERR_PROGRESS_REPORT_EXHAUSTED      = 58
    MARPA_ERR_PROGRESS_REPORT_NOT_STARTED    = 59
    MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT      = 60
    MARPA_ERR_RECCE_NOT_STARTED              = 61
    MARPA_ERR_RECCE_STARTED                  = 62
    MARPA_ERR_RHS_IX_NEGATIVE                = 63
    MARPA_ERR_RHS_IX_OOB                     = 64
    MARPA_ERR_RHS_TOO_LONG                   = 65
    MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE        = 66
    MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS       = 67
    MARPA_ERR_SOURCE_TYPE_IS_COMPLETION      = 68
    MARPA_ERR_SOURCE_TYPE_IS_LEO             = 69
    MARPA_ERR_SOURCE_TYPE_IS_NONE            = 70
    MARPA_ERR_SOURCE_TYPE_IS_TOKEN           = 71
    MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN         = 72
    MARPA_ERR_START_NOT_LHS                  = 73
    MARPA_ERR_SYMBOL_VALUED_CONFLICT         = 74
    MARPA_ERR_TERMINAL_IS_LOCKED             = 75
    MARPA_ERR_TOKEN_IS_NOT_TERMINAL          = 76
    MARPA_ERR_TOKEN_LENGTH_LE_ZERO           = 77
    MARPA_ERR_TOKEN_TOO_LONG                 = 78
    MARPA_ERR_TREE_EXHAUSTED                 = 79
    MARPA_ERR_TREE_PAUSED                    = 80
    MARPA_ERR_UNEXPECTED_TOKEN_ID            = 81
    MARPA_ERR_UNPRODUCTIVE_START             = 82
    MARPA_ERR_VALUATOR_INACTIVE              = 83
    MARPA_ERR_VALUED_IS_LOCKED               = 84
    MARPA_ERR_RANK_TOO_LOW                   = 85
    MARPA_ERR_RANK_TOO_HIGH                  = 86
    MARPA_ERR_SYMBOL_IS_NULLING              = 87
    MARPA_ERR_SYMBOL_IS_UNUSED               = 88
    MARPA_ERR_NO_SUCH_RULE_ID                = 89
    MARPA_ERR_NO_SUCH_SYMBOL_ID              = 90
    MARPA_ERR_BEFORE_FIRST_TREE              = 91
    MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT = 92
    MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT     = 93
    MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT = 94
    MARPA_ERR_RECCE_IS_INCONSISTENT          = 95
    MARPA_ERR_INVALID_ASSERTION_ID           = 96
    MARPA_ERR_NO_SUCH_ASSERTION_ID           = 97
    MARPA_ERR_HEADERS_DO_NOT_MATCH           = 98
    MARPA_ERR_NOT_A_SEQUENCE                 = 99
  end

  enum MarpaEventType
    MARPA_EVENT_NONE                  = 0
    MARPA_EVENT_COUNTED_NULLABLE      = 1
    MARPA_EVENT_EARLEY_ITEM_THRESHOLD = 2
    MARPA_EVENT_EXHAUSTED             = 3
    MARPA_EVENT_LOOP_RULES            = 4
    MARPA_EVENT_NULLING_TERMINAL      = 5
    MARPA_EVENT_SYMBOL_COMPLETED      = 6
    MARPA_EVENT_SYMBOL_EXPECTED       = 7
    MARPA_EVENT_SYMBOL_NULLED         = 8
    MARPA_EVENT_SYMBOL_PREDICTED      = 9
  end

  enum MarpaStepType
    MARPA_STEP_COUNT          = 8
    MARPA_STEP_INTERNAL1      = 0
    MARPA_STEP_RULE           = 1
    MARPA_STEP_TOKEN          = 2
    MARPA_STEP_NULLING_SYMBOL = 3
    MARPA_STEP_TRACE          = 4
    MARPA_STEP_INACTIVE       = 5
    MARPA_STEP_INTERNAL2      = 6
    MARPA_STEP_INITIAL        = 7
  end

  MARPA_KEEP_SEPARATION   = 0x1
  MARPA_PROPER_SEPARATION = 0x2
end
