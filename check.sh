
overall_status=0

for number in 1 2 3 4
do
    input_dir="Testcase$number"
    output_dir="Testcase${number}Diff"

    testcase_ok=1
    expected_count=0
    actual_count=0

    for file1 in "$input_dir"/*.1.txt
    do
        [ -f "$file1" ] || continue

        file2="${file1%.1.txt}.2.txt"
        name=$(basename "${file1%.1.txt}")
        output_file="$output_dir/${name}Diff.txt"

        if [ ! -f "$file2" ]
        then
            testcase_ok=0
            continue
        fi

        diff -u "$file1" "$file2" > /dev/null
        result=$?

        if [ "$result" -eq 0 ]
        then
            if [ -e "$output_file" ]
            then
                testcase_ok=0
            fi

        elif [ "$result" -eq 1 ]
        then
            expected_count=$((expected_count + 1))

            if [ ! -f "$output_file" ]
            then
                testcase_ok=0
            else
                if ! diff -u <(tail -n +3 "$output_file") <(diff -u "$file1" "$file2" | tail -n +3) > /dev/null
                then
                    testcase_ok=0
                fi
            fi
        else
            testcase_ok=0
        fi
    done

    if [ "$expected_count" -gt 0 ]
    then
        if [ ! -d "$output_dir" ]
        then
            testcase_ok=0
        fi
    else
        if [ -d "$output_dir" ]
        then
            testcase_ok=0
        fi
    fi

    if [ -d "$output_dir" ]
    then
        for output_file in "$output_dir"/*
        do
            [ -e "$output_file" ] || continue

            if [ -f "$output_file" ]
            then
                actual_count=$((actual_count + 1))
            else
                testcase_ok=0
            fi
        done
    fi

    if [ "$actual_count" -ne "$expected_count" ]
    then
        testcase_ok=0
    fi

    if [ "$testcase_ok" -eq 1 ]
    then
        echo "Testcase$number: PASS"
    else
        echo "Testcase$number: FAIL"
        overall_status=1
    fi
done

exit "$overall_status"
