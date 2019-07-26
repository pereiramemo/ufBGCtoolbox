#!/bin/bash -l

# set -x
set -o pipefail

###############################################################################
# 1. Load general configuration
###############################################################################

source /bioinfo/software/conf

###############################################################################
# 2. Define help
###############################################################################

show_usage(){
  cat <<EOF
  Usage: run_bgc_dom_div.bash meta <input file> <R1> <R2> <SR> \
<output directory> <options>
  
  [-h|--help] [-b|--blast t|f] [-c|--coverage t|f] [-d|--domains CHAR] 
  [-f|--font_size NUM] [-fts|--font_tree_size NUM] [-id|--identity NUM] 
  [-n|--num_iter NUM] [-oa|--output_assembly t|f] [-or|--only_rep t|f] 
  [-p|--plot_tree t|f]  [-ph|--plot_height NUM] [-pw|--plot_width NUM] 
  [-pth|--plot_tree_height NUM] [-ptw|--plot_tree_width NUM] [-t|--nslots NUM] 
  [-v|--verbose t|f] [-w|--overwrite t|f]


-h, --help	print this help
-b, --blast	t or f, run blast against reference database (default f)
-c, --coverage	t or f, use coverage to compute diversity (default f) 
-d, --domains	target domain names: comma separated list
-f, --font_size	violin plot font size (default 3). R parameter
-fts, --font_tree_size	tree plot font size (default 1). R parameter
-id, --identity	clustering minimum identity (default 0.7). mmseqs cluster parameter
-n, --num_iter	number of iterations to estimate diversity distribution (default 100)
-oa, --output_assembly	t or f, keep all assembly output directory in output (default f)
-or, --only_rep t or f, use only representative cluster sequences in tree placement (default t)
-p, --plot_tree t or f, place sequences in reference tree and generate plot
-ph, --plot_height	violin plot height (default 3). R parameter
-pw, --plot_width	violin plot width (default 3). R parameter
-pth, --plot_tree_height	tree plot height (default 12). R parameter
-ptw, --plot_tree_width	tree plot width (default 14). R parameter
-t, --nslots	number of slots (default 2). metaSPAdes, FragGeneScan, \
hmmsearch, mmseqs cluster, bwa mem and samtools parameter  
-v, --verbose	t or f, run verbosely (default f)
-w, --overwrite t or f, overwrite current directory (default f)
EOF
}

###############################################################################
# 3. Parse parameters
###############################################################################

while :; do
  case "${1}" in
#############
  -h|-\?|--help) # Call a "show_usage" function to display a synopsis, then
                 # exit.
  show_usage
  exit 1;
  ;;
#############
  -b|--blast)
  if [[ -n "${2}" ]]; then
    BLAST="${2}"
    shift
  fi
  ;;
  --blast=?*)
  BLAST="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --blast=) # Handle the empty case
  printf "ERROR: --blast requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
  -c|--coverage)
  if [[ -n "${2}" ]]; then
    COVERAGE="${2}"
    shift
  fi
  ;;
  --coverage=?*)
  COVERAGE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --coverage=) # Handle the empty case
  printf "ERROR: --coverage requires a non-empty option argument.\n"  >&2
  exit 1
  ;;   
#############
  -d|--domains)
  if [[ -n "${2}" ]]; then
    DOMAINS="${2}"
    shift
  fi
  ;;
  --domains=?*)
  DOMAINS="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --domains=) # Handle the empty case
  printf "ERROR: --domains requires a non-empty option argument.\n"  >&2
  exit 1
  ;; 
 #############
  -fs|--font_size)
   if [[ -n "${2}" ]]; then
     FONT_SIZE="${2}"
     shift
   fi
  ;;
  --font_size=?*)
  FONT_SIZE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --font_size=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -fts|--font_tree_size)
  if [[ -n "${2}" ]]; then
    FONT_TREE_SIZE="${2}"
    shift
  fi
  ;;
  --font_tree_size=?*)
  FONT_TREE_SIZE="${1#*=}" # Delete everything up to "=" and assign the 
                             # remainder.
  ;;
  --font_tree_size=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -i|--input)
  if [[ -n "${2}" ]]; then
   INPUT="${2}"
   shift
  fi
  ;;
  --input=?*)
  INPUT="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input=) # Handle the empty case
  printf "ERROR: --input requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
  -id|--identity)
  if [[ -n "${2}" ]]; then
    ID="${2}"
    shift
  fi
  ;;
  --identity=?*)
  ID="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --identity=) # Handle the empty case
  printf "ERROR: --input_dirs requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
 #############
  -n|--num_iter)
   if [[ -n "${2}" ]]; then
     NUM_ITER="${2}"
     shift
   fi
  ;;
  --num_iter=?*)
  NUM_ITER="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --num_iter=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;; 
#############
  -oa|--output_assembly)
   if [[ -n "${2}" ]]; then
     OUTPUT_ASSEM="${2}"
     shift
   fi
  ;;
  --output_assembly=?*)
  OUTPUT_ASSEM="${1#*=}" # Delete everything up to "=" and assign the 
                         # remainder.
  ;;
  --output_assembly=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -or|--only_rep)
   if [[ -n "${2}" ]]; then
     ONLY_REP="${2}"
     shift
   fi
  ;;
  --only_rep=?*)
  ONLY_REP="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --only_rep=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -o|--outdir)
   if [[ -n "${2}" ]]; then
     OUTDIR_EXPORT="${2}"
     shift
   fi
  ;;
  --outdir=?*)
  OUTDIR_EXPORT="${1#*=}" # Delete everything up to "=" and assign the 
                          # remainder.
  ;;
  --outdir=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -p|--plot_tree)
   if [[ -n "${2}" ]]; then
     PLOT_TREE="${2}"
     shift
   fi
  ;;
  --plot_tree=?*)
  PLOT_TREE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --place_tree=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -pw|--plot_width)
   if [[ -n "${2}" ]]; then
     PLOT_WIDTH="${2}"
     shift
   fi
  ;;
  --plot_width=?*)
  PLOT_WIDTH="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --plot_width=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -ph|--plot_height)
   if [[ -n "${2}" ]]; then
     PLOT_HEIGHT="${2}"
     shift
   fi
  ;;
  --plot_height=?*)
  PLOT_HEIGHT="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --plot_height=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -pth|--plot_tree_height)
   if [[ -n "${2}" ]]; then
     PLOT_TREE_HEIGHT="${2}"
     shift
   fi
  ;;
  --plot_tree_height=?*)
  PLOT_TREE_HEIGHT="${1#*=}" # Delete everything up to "=" and assign the 
                             # remainder.
  ;;
  --plot_rare_height=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -ptw|--plot_tree_width)
   if [[ -n "${2}" ]]; then
     PLOT_TREE_WIDTH="${2}"
     shift
   fi
  ;;
  --plot_tree_width=?*)
  PLOT_TREE_WIDTH="${1#*=}" # Delete everything up to "=" and assign the 
                            # remainder.
  ;;
  --plot_tree_width=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
 -R1| --reads)
   if [[ -n "${2}" ]]; then
     R1="${2}"
     shift
   fi
  ;;
  --reads=?*)
  R1="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --reads=) # Handle the empty case
  printf "ERROR: --reads requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
 -R2|--reads2)
   if [[ -n "${2}" ]]; then
     R2="${2}"
     shift
   fi
  ;;
  --reads2=?*)
  R2="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --reads2=) # Handle the empty case
  printf "ERROR: --reads2 requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
 -SR|--single_reads)
   if [[ -n "${2}" ]]; then
     SR="${2}"
     shift
   fi
  ;;
  --single_reads=?*)
  SR="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --single_reads=) # Handle the empty case
  printf "ERROR: --single_reads requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
  -t|--nslots)
   if [[ -n "${2}" ]]; then
     NSLOTS="${2}"
     shift
   fi
  ;;
  --nslots=?*)
  NSLOTS="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --nslots=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
 #############
  -v|--verbose)
   if [[ -n "${2}" ]]; then
     VERBOSE="${2}"
     shift
   fi
  ;;
  --verbose=?*)
  VERBOSE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --verbose=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -w|--overwrite)
   if [[ -n "${2}" ]]; then
     OVERWRITE="${2}"
     shift
   fi
  ;;
  --overwrite=?*)
  OVERWRITE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --overwrite=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;    
############
  --)         # End of all options.
  shift
  break
  ;;
  -?*)
  printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
  ;;
  *) # Default case: If no more options then break out of the loop.
  break
  esac
  shift
done

###############################################################################
# 4. Check mandatory parameters
###############################################################################

if [[ ! -f "${INPUT}" ]]; then
 echo "Failed. Missing input file: uproc annotation."
 exit 1;
fi

if [[ -z "${OUTDIR_EXPORT}" ]]; then
 echo "Failed. Missing output directory."
 exit 1;
fi

if [[ -z "${R1}" ]] && [[ -z "${SR}" ]]; then
 echo "Failed. Missing input reads."
 exit 1;
fi

if [[ -z "${DOMAINS}" ]]; then
 echo "Failed. Missing target domains."
 exit 1;
fi

###############################################################################
# 5. Define defaults
###############################################################################

if [[ -z "${BLAST}" ]]; then
  BLAST="f"
fi

if [[ -z "${COVERAGE}" ]]; then
  COVERAGE="f"
fi

if [[ -z "${ID}" ]]; then
  ID="0.7"
fi

if [[ -z "${FONT_SIZE}" ]]; then
  FONT_SIZE="1"
fi

if [[ -z "${NUM_ITER}" ]]; then
  NUM_ITER="100"
fi

if [[ -z "${NSLOTS}" ]]; then
  NSLOTS="2"
fi

if [[ -z "${ONLY_REP}" ]]; then
  ONLY_REP="t"
fi

if [[ -z "${OUTPUT_ASSEM}" ]]; then
  OUTPUT_ASSEM="f"
fi

if [[ -z "${PLOT_WIDTH}" ]]; then
  PLOT_WIDTH="2"
fi  

if [[ -z "${PLOT_HEIGHT}" ]]; then
  PLOT_HEIGHT="3"
fi  

if [[ -z "${PLOT_TREE_WIDTH}" ]]; then
  PLOT_TREE_WIDTH="14"
fi

if [[ -z "${PLOT_TREE_HEIGHT}" ]]; then
  PLOT_TREE_HEIGHT="12"
fi

if [[ -z "${FONT_TREE_SIZE}" ]]; then
  FONT_TREE_SIZE="1"
fi

if [[ -z "${PLOT_TREE}" ]]; then
  PLOT_TREE="f"
fi

if [[ -z "${SUBSAMPLE_NUMBER}" ]]; then
  SUBSAMPLE_NUMBER="30"
fi

if [[ -z "${VERBOSE}" ]]; then
  VERBOSE="f"
fi

###############################################################################
# 6. Load handleoutput
###############################################################################

source /bioinfo/software/handleoutput 

###############################################################################
# 7. Check output directories
###############################################################################

if [[ -d "${OUTDIR_LOCAL}/${OUTDIR_EXPORT}" ]]; then
  if [[ "${OVERWRITE}" != "t" ]]; then
    echo "${OUTDIR_EXPORT} already exist. Use \"--overwrite t\" to overwrite."
    exit
  fi
fi  

###############################################################################
# 8. Create output directories
###############################################################################

THIS_JOB_TMP_DIR="${SCRATCH}/${OUTDIR_EXPORT}"
mkdir -p "${THIS_JOB_TMP_DIR}"
  
###############################################################################
# 9. Define output vars
###############################################################################

DOM_ALL_TMP="${THIS_JOB_TMP_DIR}/dom_all.list"
ALL_HEADERS="${THIS_JOB_TMP_DIR}/all_headers.list"
ALL_HEADERS_CHECK="${THIS_JOB_TMP_DIR}/all_headers_check.list"
INPUT_SUBSET="${THIS_JOB_TMP_DIR}/uproc_outptu_subset.list"
INPUT_SUBSET_BKUP="${THIS_JOB_TMP_DIR}/uproc_outptu_subset_bkup.list"
R1_REDU="${THIS_JOB_TMP_DIR}/redu_r1.fasta"
R2_REDU="${THIS_JOB_TMP_DIR}/redu_r2.fasta"
SR_REDU="${THIS_JOB_TMP_DIR}/redu_sr.fasta"

###############################################################################
# 10. Extract domains from uproc output
###############################################################################

echo "${DOMAINS}" | sed 's/\,/\n/g' > "${DOM_ALL_TMP}"
zcat "${INPUT}" | egrep -w -f "${DOM_ALL_TMP}" | sort | uniq > "${INPUT_SUBSET}"

###############################################################################
# 11. Check (and fix) ORF header format
###############################################################################

head "${INPUT_SUBSET}" | cut -f2 -d"," > "${ALL_HEADERS_CHECK}"

if [[ -n $(egrep "_[0-9]+_[0-9]+_[+,-]$" "${ALL_HEADERS_CHECK}") ]]; then

  awk 'BEGIN {FS=","; OFS=","} \
      {
         sub("_[0-9]+_[0-9]+_[+,-]$","",$2); 
         print $0
      }' "${INPUT_SUBSET}" > "${INPUT_SUBSET_BKUP}"
      
  mv "${INPUT_SUBSET_BKUP}" "${INPUT_SUBSET}"
fi

###############################################################################
# 12. Check (and fix) old fastq header format
###############################################################################

if [[ -n $(egrep "\/[1,2]$" "${ALL_HEADERS_CHECK}") ]]; then

  awk 'BEGIN {FS=","; OFS=","} \
      { sub("\/[1,2]$","",$2); print $0}' "${INPUT_SUBSET}" > \
      "${INPUT_SUBSET_BKUP}"
      
  mv "${INPUT_SUBSET_BKUP}" "${INPUT_SUBSET}"    
fi

###############################################################################
# 13. Check number of sequences found
###############################################################################

cut -f2 -d"," "${INPUT_SUBSET}" | sort | uniq > "${ALL_HEADERS}"

NSEQ=$( wc -l "${ALL_HEADERS}" | cut -f1 -d" ")

if [[ "${NSEQ}" -lt "0" ]]; then
  echo "no reads found"
  exit 1
fi

###############################################################################
# 14. Reduce fasta file to speed up following analyses
###############################################################################

if [[ -n "${R1}" ]] && [[ -n "${R2}" ]]; then

  "${filterbyname}" \
  in="${R1}" \
  in2="${R2}" \
  out="${R1_REDU}" \
  out2="${R2_REDU}" \
  names="${ALL_HEADERS}" \
  include=t \
  overwrite=t 2>&1 | handleoutput

  if [[ "$?" -ne "0" ]]; then
    echo "filterbyname R1 and R2 failed"
    exit 1
  fi
  
fi  
  
if [[ -n "${SR}" ]]; then
  
  "${filterbyname}" \
  in="${SR}" \
  out="${SR_REDU}" \
  names="${ALL_HEADERS}" \
  include=t \
  overwrite=t 2>&1 | handleoutput
  
  if [[ "$?" -ne "0" ]]; then
    echo "filterbyname SR failed"
    exit 1
  fi
    
fi

###############################################################################
# 15. Export variables
###############################################################################

ENV="${THIS_JOB_TMP_DIR}/tmp_env"

echo -e "\
BLAST=${BLAST}
COVERAGE=${COVERAGE}
DOM_ALL_TMP=${DOM_ALL_TMP}
ID=${ID}
INPUT_SUBSET=${INPUT_SUBSET}
FONT_SIZE=${FONT_SIZE}
FONT_TREE_SIZE=${FONT_TREE_SIZE}
NSLOTS=${NSLOTS}
NUM_ITER=${NUM_ITER}
OUTPUT_ASSEM=${OUTPUT_ASSEM}
ONLY_REP=${ONLY_REP}
THIS_JOB_TMP_DIR=${THIS_JOB_TMP_DIR}
PLOT_TREE=${PLOT_TREE}
PLOT_WIDTH=${PLOT_WIDTH}
PLOT_HEIGHT=${PLOT_HEIGHT}
PLOT_TREE_HEIGHT=${PLOT_TREE_HEIGHT}
PLOT_TREE_WIDTH=${PLOT_TREE_WIDTH}
R1_REDU=${R1_REDU}
R2_REDU=${R2_REDU}
SR_REDU=${SR_REDU}
VERBOSE=${VERBOSE}" > "${ENV}"

###############################################################################
# 16. Search, assembly, cluster and, place onto ref tree (for each domain)
###############################################################################

for DOMAIN in $(cat "${DOM_ALL_TMP}"); do

  "${SOFTWARE_DIR}"/extract_assembly_cluster_and_place_wrap.bash \
  --domain "${DOMAIN}" \
  --env "${ENV}" 
   
done

###############################################################################
# 17. Clean
###############################################################################
   
rm -r "${THIS_JOB_TMP_DIR}"/tmp*
rm -r "${THIS_JOB_TMP_DIR}"/*.headers
rm -r "${ALL_HEADERS}"
rm -r "${ALL_HEADERS_CHECK}"
rm -r "${DOM_ALL_TMP}"
rm -r "${INPUT_SUBSET}"

if [[ -f "${R1_REDU}" ]]; then
  rm -r "${R1_REDU}"
  rm -r "${R2_REDU}"
fi
  
if [[ -f "${SR_REDU}" ]]; then
 rm -r "${SR_REDU}"
fi

###############################################################################
# 18. Move output for export
###############################################################################

rsync -a --delete "${THIS_JOB_TMP_DIR}" "${OUTDIR_LOCAL}"