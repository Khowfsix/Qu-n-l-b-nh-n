using QuanLyBenhAn.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyBenhAn.DAO
{
    public interface ServiceDao
    {
        void Create(Object obj);
        void Update(Object obj);
        void Delete(Object obj);

        List<Service> getAll();
        Service getById(string id);
        Service getByName(string name);
        List<Service> Search(string keyword);

    }
}
