import pandas as pd
import sys
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import mpld3

# csv 파일 업로드
csv_file = sys.argv[1]
graph_type = sys.argv[2]
data = pd.read_csv(csv_file)

columns_param = data.columns

# 데이터 시각화
def visualize(columns_param, graph_type):
    if graph_type == 'html':
        fig, axs = plt.subplots(len(columns_param)//3+1, 3, figsize=(18, len(columns_param)), constrained_layout=True) # html

        for i in range(1, len(columns_param)):
            plt.subplot(len(columns_param//3+1, 3, i)) # html

            xdata = list(data[columns_param[0]])
            ydata = list(data[columns_param[i]])
            plt.plot(xdata, ydata)
            plt.title(columns_param[i], fontsize=14) # html

            # x축 값 회전 및 개수 설정
            plt.xticks(ticks=xdata, fontsize=12) # html
            plt.locator_params(axis='x', nbins=11)

            # Counter가 %일 경우, y축 범위 0~100
            if "%" in columns_param[i]:
                plt.ylim([0, 100])
                plt.yticks(fontsize=12) # html
            else:
                # y축 표시 형식 (3자리마다 ,)
                label_format = '{:,.0f}'
                ticks_loc = plt.gca().get_yticks()
                plt.gca().yaxis.set_major_locator(mticker.FixedLocator(ticks_loc))
                plt.gca().set_yticklabels([label_format.format(x) for x in ticks_loc], fontsize=12) # html
            # html 결과 출력
            mpld3.save_html(fig, csv_file[:-4]+'.html')
            print(csv_file[:-4] + '.html saved successfully\n')

    elif graph_type == 'png':
        fig, axs = plt.subplots(10, len(columns_param)//10+1, figsize=((len(columns_param)//10+1)*10, 80), constrained_layout=True) #png
        
        for i in range(1, len(columns_param)):
            plt.subplot(10, len(columns_param)//10+1, i) # png

            xdata = list(data[columns_param[0]])
            ydata = list(data[columns_param[i]])
            plt.plot(xdata, ydata)
            plt.title(columns_param[i], fontsize=17) # png

            # x축 값 회전 및 개수 설정
            plt.xticks(ticks=xdata, fontsize=12) # png
            plt.locator_params(axis='x', nbins=9)

            # Counter가 %일 경우, y축 범위 0~100
            if "%" in columns_param[i]:
                plt.ylim([0, 100])
                plt.yticks(fontsize=17) # png
            elif 0 <= max(data[columns_param[i]]) <= 1:
                label_format = '{:,.4f}'
                ticks_loc = plt.gca().get_yticks()
                plt.gca().yaxis.set_major_locator(mticker.FixedLocator(ticks_loc))
                plt.gca().set_yticklabels([label_format.format(x) for x in ticks_loc], fontsize=17)
            else:
                # y축 표시 형식 (3자리마다 ,)
                label_format = '{:,.0f}'
                ticks_loc = plt.gca().get_yticks()
                plt.gca().yaxis.set_major_locator(mticker.FixedLocator(ticks_loc))
                plt.gca().set_yticklabels([label_format.format(x) for x in ticks_loc], fontsize=17) # html
            # png 결과 출력
            plt.savefig(csv_file[:-4] + ".png")
            print(csv_file[:-4] + '.png saved successfully\n')

    while(True):
        graph_type = input('Graph type(html or png): ')
        if graph_type == 'html' or graph_type == 'png':
            break
        else:
            print("Invalid type (html or png)")

visualize(columns_param, graph_type)
