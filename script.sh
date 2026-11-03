
for number in 1 2 3 4
do
    input_dir="Testcase$number"
    output_dir="Testcase${number}Diff"

    rm -rf "$output_dir"

    for file1 in "$input_dir"/*.1.txt
    do
        [ -f "$file1" ] || continue

        file2="${file1%.1.txt}.2.txt"

        name=$(basename "${file1%.1.txt}")
        output_file="$output_dir/${name}Diff.txt"

        if [ ! -f "$file2" ]
        then
            echo "Missing file: $file2" >&2
            exit 1
        fi

        diff -u "$file1" "$file2" > /dev/null
        result=$?

        if [ "$result" -eq 1 ]
        then
            mkdir -p "$output_dir"
            diff -u "$file1" "$file2" > "$output_file"
        elif [ "$result" -ne 0 ]
        then
            echo "Error comparing files" >&2
            exit 1
        fi
    done
done
