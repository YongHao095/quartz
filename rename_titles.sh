#!/bin/bash

# 遍历 content 文件夹中的所有 .md 文件
find content -name "*.md" | while read file; do
  # 获取文件名（不含路径和扩展名）
  filename=$(basename "$file" .md)
  
  # 如果文件名不是 index，则处理
  if [ "$filename" != "index" ]; then
    echo "处理文件: $file"
    
    # 创建临时文件
    temp_file=$(mktemp)
    
    # 检查是否已有 frontmatter
    if head -n 1 "$file" | grep -q "^\-\-\-$"; then
      # 已有 frontmatter，更新 title
      awk -v filename="$filename" '
        /^---$/ { in_frontmatter = !in_frontmatter; print; next }
        in_frontmatter && /^title:/ { 
          print "title: " filename; updated = 1; next 
        }
        { print }
        END {
          if (!updated && in_frontmatter) {
            print "title: " filename
          }
        }
      ' "$file" > "$temp_file"
    else
      # 没有 frontmatter，添加 frontmatter
      echo "---" > "$temp_file"
      echo "title: $filename" >> "$temp_file"
      echo "---" >> "$temp_file"
      cat "$file" >> "$temp_file"
    fi
    
    # 替换原文件
    mv "$temp_file" "$file"
  fi
done

echo "完成！所有文件的 title 已设置为文件名。"
