%% Initial system comparison
plotEnbaler = 1;
if plotEnbaler == 1
    figure
    for i = 1:1:Nx
        ax(i) = subplot(size(output,2)-1,1,i);
        plot(output(:,i),'b','LineWidth',0.5)
        hold on
        plot(y_init.OutputData(:,i),'r','LineWidth',0.5)
        ylabel(['$h$' num2str(i) '[$m$]'],'interpreter','latex');
        leg = legend('Data','Model','Location','NorthEast');
        set(leg, 'Interpreter', 'latex');
        if i == 1
            title('Initial model - level','interpreter','latex')
        end
    end
    xlabel('Time [10 min]','interpreter','latex');
linkaxes(ax, 'x')

Qout_init = y_init.OutputData(:,Nx+1);

figure
plot(Q(2,:),'b','LineWidth',0.5)
hold on
plot(Qout_init,'r','LineWidth',0.5)
ylabel('$Q_{out}$  [$\frac{m^3}{h}$]','interpreter','latex');
xlabel('Time [10 min]','interpreter','latex');
leg = legend('Data','Model','Location','NorthEast');
set(leg, 'Interpreter', 'latex');
title('Initial model - flow','interpreter','latex')
end

%% Estimated system comparison
plotEnbaler = 1;
if plotEnbaler == 1
    figure
    for i = 1:1:Nx
        ax(i) = subplot(size(output,2)-1,1,i);
        plot(output(:,i),'b','LineWidth',0.5)
        hold on
        plot(y_final.OutputData(:,i),'r','LineWidth',0.5)
        leg = legend('Data','Model','Location','NorthEast');
        set(leg, 'Interpreter', 'latex');
        ylabel(['$h$' num2str(i) '[$m$]'],'interpreter','latex');
        if i == 1
            title('Estimated model - level','interpreter','latex')
        end
    end
    xlabel('Time [10 min]','interpreter','latex');
end
linkaxes(ax, 'x')

Qout_est = y_final.OutputData(:,Nx+1);

figure
plot(Q(2,:),'b','LineWidth',0.5)
hold on
plot(Qout_est,'r','LineWidth',0.5)
ylabel('$Q_{out}$  [$\frac{m^3}{h}$]','interpreter','latex');
xlabel('Time [10 min]','interpreter','latex');
leg = legend('Data','Model','Location','NorthEast');
set(leg, 'Interpreter', 'latex');
title('Estimated model - flow','interpreter','latex')

%% g(z) non-linear function 
function y = g(z,p3)    
    y = ((z).^(5/3)) ./ ((z + p3).^(2/3));        
end